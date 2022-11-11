import Config

# I assume floating point representation from 0 to 1 is acceptable for representing this value
default_fulfillment_overhead_percentage = "0.15"
{parsed_fulfillment_overhead_percentage, _} = Float.parse(System.get_env("FULFILLMENT_OVERHEAD_PERCENTAGE") || default_fulfillment_overhead_percentage)

config :visilitator, Visilitator.User,
  fulfillment_overhead_percentage: parsed_fulfillment_overhead_percentage
