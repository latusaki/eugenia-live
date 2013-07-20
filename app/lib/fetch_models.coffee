Spine = require('spine')
model_names = ["palette_specification", "palette", "link_shape",
          "node_shape", "drawing", "node", "link"]


for model_name in model_names
  model = require("models/#{model_name}")
  model.extend(Spine.Model.Realtime) unless model_name is "palette_specification"
  if(model_name is "palette_specification")
	  model.fetch()

# Add if statement. If model does not extend Realtime, call model.fetch .