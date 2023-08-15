# Rayhub

Store and process device readings from the field.

Use event sourcing to decouple device reading events from their aggregation into summary statistics over various types of measurements.

## Installation and usage

Make sure you have the following installed:
* `ruby (>= 3.2.2)`
* `bundler`

From here, there are two options outlined in the next two sections:
* Clone this repo and build and run it locally
* Install the application as a gem

### Clone and build locally
Clone this repo.
Build:

    $ bundle install
Run the server:

    $ HANAMI_ENV=production bundle exec puma -C config/puma.rb

### Install as a gem
[Create a personal access token (classic) on GitHub](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic) with the `read:packages` scope.

Install the gem using the above token by executing:

    $ gem install rayhub -s https://GITHUB_USERNAME:GITHUB_PERSONAL_ACCESS_TOKEN@rubygems.pkg.github.com/nihil2501/

Run the server:

    $ rayhub

## Local E2E testing

Perform an e2e test locally by taking inspiration from the [bin/e2e](bin/e2e) bash script.

## API specification
Create device readings:

    $ POST http://localhost:2300/device_readings
    {
        "id": "device-1",
        "readings": [
            {
                "timestamp": "2021-09-29T16:08:15+01:00",
                "count": 2
            }
        ]
    }

    Parameter schema:
        params do
          required(:id).filled(:string)
          required(:readings).array(:hash) do
            required(:timestamp).filled(:date_time)
            required(:count).filled(:integer)
          end
        end

    Responses:
        202 (Accepted)
        422 (Unprocessable Entity), <Error object>

Read a device readings summary (projected according to the `attributes[]` query string parameter):

    $ GET http://localhost:2300/device_readings/summary?id=device-1&attributes[]=latest_timestamp&attributes[]=cumulative_count

    Parameter schema:
        params do
          required(:id).filled(:string)
          optional(:attributes).array(:string)
        end

    Responses:
        200 (OK), {"latest_timestamp": "2021-09-29T16:08:15+01:00", "cumulative_count": 2}
        422 (Unprocessable Entity), <Error object>

## Project structure
* API shell defined under the [app/](app/) directory
    - `/device_readings` collection scope
    - with a batch create action on the collection for a given device at [app/actions/device_readings/create](app/actions/device_readings/create)
    - and a summary read action on the collection for a given device at [app/actions/device_readings/summary](app/actions/device_readings/summary)
* Core logic defined under the [lib/](lib/) directory
    - Device readings are modeled as events under [lib/rayhub/events/device_reading.rb](lib/rayhub/events/device_reading.rb)
    - Device reading summaries are modeled as aggregates under [lib/rayhub/aggregates/device_reading.rb](lib/rayhub/aggregates/device_reading.rb)
    - Non-domain event sourcing logic is defined under [lib/event_sourcing.rb](lib/event_sourcing.rb)

## Architecture
This is an event sourcing system. Events are submitted by the client which we create and immediately return. These will be accumulated into aggregates at a later time. When a client requests a summary we return these aggregates. In this toy application, we only simulate the notion that aggregates are derived offline, but we still demonstrate the decoupling afforded by the paradigm. In this simulation, we maintain queues on a per-device-per-attribute basis and when a summary request arrives, drain only the corresponding queue. Aggregates also save event timestamps in a set which we check in order to skip redundancies and make the system idempotent. This simulates something like a unique DB index for an events table. We kind of presuppose that this system will get significantly more writes than reads and choose to delay aggregation to only when it is demanded, but the decoupling in the design means that other strategies can exist where some amount of work is performed offline and then completed synchronously on demand if freshness is a big requirement. Strategies can even alter dynamically over time based on some feedback into the system.

## Future extensions
### Domain extensions
* More kinds of signals
* More kinds of devices
* More summary statistics
* Associate devices with essential attributes
	- (latitude, longitude)
	- object_id: this device is associated with measuring some particular object
* Anomolous _device_ behavior detection
  - Device behavior rather than phenomenon behavior so that this component concerns device operation per se. Detection afforded by having two devices read the same phenomenon for instance?
### Technical extensions
* Persistence
* Replayability
* Payload schema versioning (hard problem of event sourcing I think)
* Cache and efficiently re-use the output of every (since, until) input so that API can offer that interface?
* Measurement library
* Adding to a count concurrently without race conditions and minimizing locking overhead is a well-known problem in concurrent programming apparently
* Difference between `reading.taken_at` and `reading.received_at`: if we wanted to know what was knowable in the past, we'd have to care about the latter
