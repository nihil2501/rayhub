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

    it "returns a device reading summary" do
      get("/device_readings/summary", params, headers)

      expect(last_response).to be_ok
      expect(last_response.body).to eq({
        "latest_timestamp" => nil,
      }.to_json)
    end
  end

  context "given invalid params" do
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
