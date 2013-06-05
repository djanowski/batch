require_relative "../lib/batch"

payload = 500.times.to_a

Batch.start("Processing items", payload) do |item|
  1 / (item % 100)

  sleep(0.01)
end
