Tool = require('controllers/tool')
CreateNode = require('models/commands/create_node')

class NodeTool extends Tool
  parameters: {'shape' : null}
  timer:0
  
  onMouseDown: (event) ->
    if @parameters.shape
      @parameters.position = event.point
      @run(new CreateNode(@drawing, @parameters))
      @clearSelection()
      
  onMouseMove: (event) ->

    # if @parameters.shape
    #   @clearSelection()
    #   @select(@hitTester.nodeAt(event.point))
    #τεστινγ ψομιτ
  
module.exports = NodeTool