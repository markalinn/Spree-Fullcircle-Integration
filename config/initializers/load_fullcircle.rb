raw_config = File.read(::Rails.root.to_s + "/config/fullcircle.yml")
FullCircleConfig = YAML.load(raw_config)[Rails.env]