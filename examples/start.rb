require_relative "../lib/batch"

payload = 500.times.to_a

Batch.start("Working", payload) do |item|
end
