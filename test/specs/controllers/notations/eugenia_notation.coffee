require = window.require

describe 'EugeniaNotation', ->
  EugeniaNotation = require('controllers/notations/eugenia_notation')
  NodeShape = require('models/node_shape')
  LinkShape = require('models/link_shape')

  beforeEach ->
    @notation = new EugeniaNotation

  it 'can represent a minimal nodeshape', ->
    shape = new NodeShape
      name: "Simple"
      label:
        placement: "none"
      elements: [
        figure: "rectangle"
      ]
    
    expect(@notation.reconstruct(shape)).toEqual(shape.toJSON())
  
  it 'sets label.placement to none when there is no label', ->
    shape = new NodeShape
      name: "Simple"
      elements: [
        figure: "rectangle"
      ]
    
    expect(@notation.serialiseNode(shape)).toMatch(/label.placement="none"/)
  
  it 'can represent a nodeshape with properties', ->
    shape = new NodeShape
      name: "Simple"
      label:
        placement: "none"
      elements: [
        figure: "rectangle"
      ]
      properties: ["name", "id"]

    expect(@notation.reconstruct(shape)).toEqual(shape.toJSON())
  
  it 'can represent additional properties of each element', ->
    shape = new NodeShape
      name: "Simple"
      label:
        placement: "none"
      elements: [
        figure: "rectangle"
        borderColor: "rgba(255, 0, 0, 1)"
        fillColor: "rgba(255, 0, 0, 1)"
        size: { width: 10, height: 40 }
      ]

    expect(@notation.reconstruct(shape)).toEqual(shape.toJSON())
  
  
  it 'can represent only the first element of a multielement node shape', ->
    shape = new NodeShape
      name: "Simple"
      label:
        placement: "none"
      elements: [
        {
          figure: "rectangle"
          borderColor: "rgba(255, 0, 0, 1)"
          fillColor: "rgba(0, 255, 0, 1)"
          size: { width: 10, height: 40 }
        },
        {
          figure: "ellipse"
          borderColor: "rgba(0, 0, 255, 1)"
          fillColor: "rgba(255, 255, 0, 1)"
          size: { width: 5, height: 5 }
        }
      ]

    expected = shape.toJSON()
    expected.elements = [expected.elements[0]]

    expect(@notation.reconstruct(shape)).toEqual(expected)

  
  it 'can represent a minimal labelled nodeshape', ->
    shape = new NodeShape
      name: "Simple"
      label: 
        for: ["name"]
        pattern: "{0}"

    expect(@notation.reconstruct(shape)).toEqual(shape.toJSON())
    expect(@notation.serialiseNode(shape)).not.toMatch(/label.placement="none"/)
    
  it 'can represent additional properties of a labelled nodeshape', ->
    shape = new NodeShape
      name: "Simple"
      label: 
        for: ["name", "state"]
        pattern: "{1} --> {0}"
        placement: "external"
        color: "rgba(128, 0, 128, 1)"
        length: 20

    expect(@notation.reconstruct(shape)).toEqual(shape.toJSON())
   
    
  it 'can represent a minimal linkshape', ->
    shape = new LinkShape
      name: "Simple"
      color: "rgba(0, 0, 0, 1)" 
      style: "solid"

    expect(@notation.reconstruct(shape)).toEqual(shape.toJSON())
    
  it 'includes properties for ends when serialising a link', ->
    shape = new LinkShape
      name: "Simple"
      color: "rgba(0, 0, 0, 1)" 
      style: "solid"

    serialised = @notation.serialise(shape)

    expect(serialised).toMatch("source=\"source\"")
    expect(serialised).toMatch("target=\"target\"")

  it 'includes references to ends when serialising a link', ->
    shape = new LinkShape
      name: "Simple"
      color: "rgba(0, 0, 0, 1)" 
      style: "solid"

    serialised = @notation.serialise(shape)

    expect(serialised).toMatch("ref .* source;")
    expect(serialised).toMatch("ref .* target;")