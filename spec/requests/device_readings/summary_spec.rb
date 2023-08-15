# spec/requests/books/create_spec.rb

RSpec.describe "GET /device_readings/summary", type: [:request] do
  let(:headers) do
    {
      "HTTP_ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json",
    }
  end

  context "given valid params" do
    let(:params) do
      {
        "id" => "36d5658a-6908-479e-887e-a949ec199272",
        "attributes" => ["latest_timestamp"],
      }
    end

    it "404s with no prior device readings" do
      get("/device_readings/summary", params, headers)

      expect(last_response).to be_not_found
    end

    context "when there have been device readings" do
      before do
        post_params = {
          "id" => "36d5658a-6908-479e-887e-a949ec199272",
          "readings" => [
            {
              "timestamp" => "2021-09-29T16:08:15+01:00",
              "count" => 2
            },
            {
              "timestamp" => "2021-09-29T16:09:15+01:00",
              "count" => 15
            }
          ],
        }

        post("/device_readings", post_params.to_json, headers)
      end

      it "returns a device reading summary" do
        get("/device_readings/summary", params, headers)

        expect(last_response).to be_ok
        expect(last_response.body).to eq({
          "latest_timestamp" => "2021-09-29T16:09:15+01:00",
        }.to_json)
      end
    end
  end

  context "given invalid params" do
    context "missing necessary id param" do
      let(:params) do
        {}
      end

      it "returns 422 unprocessable" do
        get("/device_readings/summary", params, headers)

        expect(last_response).to be_unprocessable
        expect(last_response.body).to eq({
          "errors" => {
            "id" => ["is missing"],
          }
        }.to_json)
      end
    end
  end
end
