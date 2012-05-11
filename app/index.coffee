require('lib/setup')

# Spine = require('spine')
CanvasRenderer = require('views/canvas_renderer')
Toolbox = require('controllers/toolbox')

PetriNetPalette = require('models/petri_net_palette')
StateMachinePalette = require('models/state_machine_palette')

class App extends Spine.Controller
  constructor: ->
    super
    
    new StateMachinePalette()
    # new PetriNetPalette()
    new CanvasRenderer($('canvas')[0])
    new Toolbox(el: $('#toolbox'))
      
module.exports = App
    