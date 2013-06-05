require_relative "../lib/batch"

payload = 500.times.to_a

Batch.start("Big data", payload) do |item|
  sleep(item / 100.0)
end
