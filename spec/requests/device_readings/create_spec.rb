# spec/requests/books/create_spec.rb

RSpec.describe "POST /device_readings", type: [:request] do
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
    end

    it "creates a device reading" do
      post("/device_readings", params.to_json, headers)

      expect(last_response).to be_accepted
      expect(last_response.body).to eq(%{})
    end
  end

  context "given invalid params" do
    context "due to missing all params" do
      let(:params) do
        {}
      end

      it "returns 422 unprocessable" do
        post("/device_readings", params.to_json, headers)

        expect(last_response).to be_unprocessable
        expect(last_response.body).to eq({
          "errors" => {
            "id" => ["is missing"],
            "readings" => ["is missing"],
          }
        }.to_json)
      end
    end

    context "due to all reading missing params" do
      let(:params) do
        {
          "id" => "36d5658a-6908-479e-887e-a949ec199272",
          "readings" => [{}],
        }
      end

      it "returns 422 unprocessable" do
        post("/device_readings", params.to_json, headers)

        expect(last_response).to be_unprocessable
        expect(last_response.body).to eq({
          "errors" => {
            "readings" => {
              "0" => {
                "timestamp" => ["is missing"],
                "count" => ["is missing"],
              }
            },
          }
        }.to_json)
      end
    end
  end
end
