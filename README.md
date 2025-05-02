# US Address Service

US Address Service to verify and cleanse addresses, using data supplied by Melissa Data.

Features:
- Extremely fast
  - < 4 ms per request
- Scalable
  - Up to 2,000 concurrent HTTP Web requests per instance.
  - Process over 24 million requests per hour with 2 docker images.
- HTTP API Web Service, with JSON messages.
- Calls Melissa Data Address Object to cleanse and verify the supplied address.
- Returns the cleansed address and the delivery_point if the address is valid.
- Uses Plug Cowboy directly as the HTTP Server.
- Support for Bugnsag error reporting.

## License

In order to build the US Address Service you need to purchase a Melissa Data, Data Quality Suite (DQS) license.

Contact Melissa Data to obtain the license. The product that needs to be purchased is called `AddressObject`.

They will also give you a URL to download the files from, similar to:
`https://releases.melissadata.net/download/product/latest/DataQualitySuite?id=...`

This URL needs to be supplied below in the environment variable `MD_WEB_URL` to download the software.

## Download the Melissa Data packages

Set the download URL environment variable using the actual value from above:

    export MD_WEB_URL="https://releases.melissadata.net/download/product/latest/DataQualitySuite?id=..."

Set the license obtained above as an environment variable:

    export MD_LICENSE="................................."

After pulling the source code from github, change into the source directory:

    cd us_address_service

One time exercise, download the latest Melissa Data Package:

    ./download_melissa_data.sh

Remove raw image download from above step that is no longer needed.

    rm -rf ../dqs

## Build Production Docker Image

The US Address Service is run as a docker container, either locally, or on your favorite cloud provider.

The docker image consists of code built from this source code, and is also packaged with the above 
Melissa Data Software and database.

Download and Install [Docker Desktop](https://www.docker.com/products/docker-desktop) (If not already installed)

Build production docker image, including the Melissa Data software downloaded in the previous section.

    docker build --build-arg MD_LICENSE=$MD_LICENSE -t us_address_service .

Note:
- Tests are run during the above build steps to ensure that the source code is working as expected against the 
  version of the Melissa Data software that was downloaded.

### Verify Production Docker Image

Start Web Server:

    docker run --rm -p 127.0.0.1:8080:8080 us_address_service

Verify Melissa Data license and version information

    curl http://localhost:8080/version

Should see something similar to:

~~~json
{"build_number":"17236","database_date":"2021-03-15","expiration_date":"06-30-2021","initialize_status":"No error.","license_expiration_date":"2021-09-28"}
~~~

If the build number contains the word `DEMO` then the environment variable `MD_LICENSE` was not set correctly.

Verify a test address:

    curl "http://localhost:8080/address?address=2811+Safe+Harbor+Drive&city=Tampa&state=FL&zip=33618"

It should return something similar to:

~~~json
{"address":"2811 Safe Harbor Dr","address2":"","address_key":"33618453411","address_range":"2811","address_type":"Street","address_type_code":"S","city":"Tampa","delivery_point":"33618453411","garbage":"","plus4":"4534","post_direction":"","pre_direction":"","private_mailbox_name":"","private_mailbox_number":"","result_codes":"AS01","state":"FL","street_name":"Safe Harbor","suffix":"Dr","suite":"","suite_name":"","suite_range":"","time_zone":"Eastern Time","time_zone_code":"05","zip":"33618"}
~~~

Performance Testing using Apache Bench:

    ab -n 1000 -c 10 http://localhost:8080/version
    ab -n 1000 -c 10 "http://localhost:8080/address?address=2811+Safe+Harbor+Drive&city=Tampa&state=FL&zip=33618"

### Docker Commands

Some other generally useful commands for working with the new docker container.

Start a console with application loaded:

    docker run --rm -it us_address_service bin/us_address_service start_iex

Open a bash console:

    docker run --rm -it us_address_service bash

Kill running container

    docker ps
    docker kill `container_id`

Debug partial build

    docker images
    docker run -it --rm `image_id` bash

To cleanup local partial and untagged builds.

    docker system prune -f

## Development and Testing

This section only applies when contributing to the US Address Service Elixir project.

Since the Melissa Data C libraries cannot run on Mac or Windows, all development should be done within a 
docker container.

Download and install docker if not already installed. Or use Colima:
    `brew install colima docker`

Build development docker image

    docker build --platform linux/amd64 --build-arg MD_LICENSE=$MD_LICENSE -t us_address_development --file development.Dockerfile .

Launch development console:

    docker run --platform linux/amd64 -it --rm -p 4000:4000 --volume `pwd`:/src us_address_development bash

Install dependencies

    cd us_address_service
    mix local.hex --force
    mix local.rebar --force
    mix deps.get

Run the tests:

    mix clean
    mix test

Start the server

    mix run --no-halt

From another terminal window:

    curl http://localhost:4000/ping
    curl http://localhost:4000/version
    curl "http://localhost:4000/address?address=2811+Safe+Harbor+Drive&city=Tampa&state=FL&zip=33618"

Open a Console:

    iex -S mix

### Notes

- The call to `USAddress.Nif.init/0` uses the dirty scheduler since the call takes longer than 1ms.
- Files needed for Address Verify (531MB)
  mdAddr.dat  mdAddr.lic  mdAddr.nat  mdAddr.str

### Future enhancements?

The following add-ons are available from Melissa Data that are not yet supported by this service. Pull requests welcome.

- Support DPV:
  Verifying that delivery point is actually deliverable by the USPS
  dph256.dte  dph256.hsc  dph256.hsn  dph256.hsx dph256.hsa  dph256.hsf  dph256.hsv lcd

- Support LACS via SetPathToLACSLinkDataFiles:
  Converts rural addresses to city addresses for emergency services
  mdLACS256.dat

- Support SuiteLink via SetPathToSuiteLinkDataFiles:
  SuiteLink matching or updating of your addresses will not occur
  (mdSteLink.dat)

- Support Canadian Addresses

## Versioning

This project uses [Semantic Versioning](http://semver.org/).

## Author

[Reid Morrison](https://github.com/reidmorrison)

## Contributors

[Contributors](https://github.com/reidmorrison/us_address_service/graphs/contributors)

