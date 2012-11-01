NodeShape = require("models/node_shape")

class EugeniaNotation 
  reconstruct: (item) ->
    @deserialise(@serialise(item))
  
  serialisePalette: (palette) ->
    @serialisePaletteHeader(palette) + @serialisePaletteBody(palette)
    
  serialisePaletteHeader: (palette) ->
    nodeShapeContainmentReferences = ("  val #{ns.name}[*] #{ns.name}s;" for ns in palette.nodeShapes().all()).join('\n')
    
    """@namespace(uri="yourlanguage", prefix="yourlanguage")
    package yourlanguage;

    @gmf.diagram(foo="bar")
    class Root {
    #{nodeShapeContainmentReferences}
    }\n\n"""
  
  serialisePaletteBody: (palette) ->
    shapes = palette.nodeShapes().all().concat palette.linkShapes().all()
    serialisedShapes = (@serialise(shape) for shape in shapes)
    serialisedShapes.join('\n\n')
  
  serialise: (item) ->
    if item instanceof NodeShape
       @serialiseNode(item)
    else
       @serialiseLink(item)
    
  serialiseNode: (item) ->
    properties = ''
    
    if item.elements and item.elements.length > 0
      e = item.elements[0]
      
      if e.borderColor
        properties += ", " if properties
        properties += "border.color=\"#{@serialiseColor(e.borderColor)}\""
      
      if e.fillColor
        properties += ", " if properties
        properties += "color=\"#{@serialiseColor(e.fillColor)}\""
      
      if e.figure
        properties += ", " if properties
        properties += "figure=\"#{e.figure}\""
      
      if e.size and e.size.width and e.size.height
        properties += ", " if properties
        properties += "size=\"#{e.size.width},#{e.size.height}\""
    
    
    if item.label
      l = item.label
      
      if l.for
        properties += ", " if properties
        properties += "label=\"#{l.for.join(",")}\""
        
      if l.pattern
        properties += ", " if properties
        properties += "label.pattern=\"#{l.pattern}\""
      
      if l.placement
        properties += ", " if properties
        properties += "label.placement=\"#{l.placement}\""
     
      if l.length
        properties += ", " if properties
        properties += "label.length=\"#{l.length}\""
      
      if l.color
        properties += ", " if properties
        properties += "label.color=\"#{@serialiseColor(l.color)}\""
    
    """
    @gmf.node(#{properties})
    class #{item.name} {
    }
    """
  
  serialiseLink: (item) ->
    item.style or= "solid"
    item.color or= "black"
    
    """
    @gmf.link(style="#{item.style}", color="#{@serialiseColor(item.color)}")
    class #{item.name} {
      
    }
    """

  serialiseColor: (color) ->
    c = new paper.Color(color)
    "rgb(#{c.red*255},#{c.green*255},#{c.blue*255})"
  
  
  deserialise: (definition) ->
    if definition.match(/@gmf.node/)
      @deserialiseNode(definition)
    else
      @deserialiseLink(definition)
  
  deserialiseNode: (definition) ->
    node = {}
    node.name = @deserialiseName(definition)
    
    properties = @deserialiseProperties(definition)
    
    label = {}
    if properties['label']
      label.for = properties.label.split(',')
      delete properties.label
    
    if properties['label.placement']
      label.placement = properties['label.placement']
      delete properties['label.placement']
    
    if properties['label.pattern']
      label.pattern = properties['label.pattern']
      delete properties['label.pattern']
    
    if properties['label.color']
      label.color = @deserialiseColor(properties['label.color'])
      delete properties['label.color']
    
    if properties['label.length']
      label.length = parseInt(properties['label.length'])
      delete properties['label.length']
    
    
    if properties['border.color']
      properties.borderColor = @deserialiseColor(properties['border.color'])
      delete properties['border.color']
      
    if properties.color
      properties.fillColor = @deserialiseColor(properties.color)
      delete properties.color
    
    if properties.size
      [width, height] = properties.size.split(",")[0..1]
      properties.size =
        width: parseInt(width)
        height: parseInt(height)
    
    node.elements = [properties] unless $.isEmptyObject(properties)
    node.label = label unless $.isEmptyObject(label)
    
    # console.log(node)
    node
    
  deserialiseLink: (definition) ->
    link = @deserialiseProperties(definition)
    link.name = @deserialiseName(definition)
    link.color = @deserialiseColor(link.color) if link.color
    link
  
  deserialiseColor: (color) ->
    [all,r,g,b] = color.match("rgb\\((\\d+),(\\d+),(\\d+)\\)")
    new paper.Color(r/255, g/255, b/255).toCssString()
    
  deserialiseName: (definition) ->
    class_pattern = /class\s+(\w*)/
    definition.match(class_pattern)[1]
    
  deserialiseProperties: (definition) ->
    result = {}
    
    properties_pattern = /@gmf\.\w*\((.*)\)/
    properties = definition.match(properties_pattern)[1]
    for property in properties.split(', ')
      property_pattern = /([^=]*)="([^"]*)"/
      [key, value] = property.match(property_pattern)[1..2]
      result[key] = value
    
    result

module.exports = EugeniaNotation