Rails.application.config.to_prepare do
  SolidCable::Record.connects_to database: { writing: :production, reading: :production } if defined?(SolidCable::Record)
  SolidQueue::Record.connects_to database: { writing: :production, reading: :production } if defined?(SolidQueue::Record)
end