'use strict'

should = require 'should'
_ = require 'underscore'

path = require '../util/path'
JsonLinker = require path.toApp('json-linker')

CONSTANT_DEFAULT_ID_FIELD = 'id'
CONSTANT_DEFAULT_ROOT_ATTRIBUTE = 'model'

describe 'json-linker', ->

  id = 'abc123'

  authorId = 'tt123'
  author =
    id: authorId
    name: 'Chanchito'

  tagId1 = 'qwer234'
  tagId2 = 'zxc345'
  tags = [
    { id: tagId1, name: 'tag1' }
    { id: tagId2, name: 'tag2' }
  ]

  model = null
  json = null
  linker = null
  unlinker = null

  beforeEach ->
    model =
      id: id
      author: author
      tags: _.clone(tags)
    json = new JsonLinker(model)
      .links('author', 'tags')
      .toJson()
    linker = new JsonLinker(model)
    unlinker = new JsonLinker(json)

  describe '#constructor', ->

    it 'takes a model and a root attribute', ->
      JsonLinker.length.should.eql 2

    it 'can default the root attribute', ->
      linker._rootAttr.should.eql CONSTANT_DEFAULT_ROOT_ATTRIBUTE

  describe '#links', ->

    it 'saves a varargs properties list', ->
      linker.links.length.should.eql 1
      props = ['tags', 'author']

      linker.links.apply(linker, props)
      linker._links.length.should.eql props.length
      linker._links.forEach (link, indx) ->
        link.name.should.eql props[indx]

    it 'saves an array properties list', ->
      linker.links.length.should.eql 1
      props = ['tags', 'author']

      linker.links.call(linker, props)
      linker._links.length.should.eql props.length
      linker._links.forEach (link, indx) ->
        link.name.should.eql props[indx]

    it 'is callable multiple times', ->
      props1 = ['tags', 'author']
      props2 = ['another']

      linker.links.apply(linker, props1)
      linker.links.apply(linker, props2)
      linker._links.length.should.eql props1.length + props2.length

    it 'saves the link field as a default id', ->
      props = ['tags', 'author']

      linker.links.apply(linker, props)
      linker._links.forEach (link) ->
        link.id.should.eql CONSTANT_DEFAULT_ID_FIELD

    it 'returns linker for arg linking', ->
      linker.links().should.eql linker

  # TODO: uncomment when we support other id fields well
#  describe '#link', ->
#
#    it 'allows setting a different id field'

  describe '#toJson', ->

    it 'outputs default root attribute', ->
      actual = linker.toJson()
      actual.should.have.property 'model'

    it 'outputs custom root attribute', ->
      linker = new JsonLinker(model, 'customRoot')
      actual = linker.toJson()
      actual.should.have.property 'customRoot'

    it 'put single model in array of one', ->
      actual = linker.toJson()
      actual.model[0].should.eql model

    # TODO: uncomment when we support array models well
#    it 'directly transfers model array', ->
#      arrayModel = [{ something: 'here' }, { something: 'else' }]
#      linker = new JsonLinker(arrayModel, 'myArray')
#      actual = linker.toJson()
#      actual.should.have.property 'myArray', arrayModel

    it 'puts a links attribute in model', ->
      actual = linker
        .links('tags', 'author')
        .toJson()
      actual.model[0].should.have.property 'links'

    it 'puts a linked attribute next to model', ->
      actual = linker
        .links('tags', 'author')
        .toJson()
      actual.should.have.property 'linked'

    it 'has a linked for a single links entry', ->
      linkKey = 'tags'
      actual = linker
        .links(linkKey)
        .toJson()
      actual.linked.should.have.property linkKey

    it 'has a linked entry for every links entry', ->
      actual = linker
        .links('tags', 'author')
        .toJson()
      Object.keys(actual.model[0].links).forEach (linkKey) ->
        actual.linked.should.have.property linkKey

    it 'has an alias of toJSON', ->
      linker.toJSON.should.be.type 'function'

    it 'has no linked attribute if #links never called', ->
      actual = new JsonLinker(model).toJson()
      actual.should.not.have.property 'linked'

    it 'has no linked attribute if nothing found to link', ->
      actual = new JsonLinker(model)
        .links('unfound')
        .toJson()
      actual.should.not.have.property 'linked'

  describe '#toEmbeddedModel', ->

    it 'strips the default root attribute', ->
      actual = unlinker.toEmbeddedModel()
      actual.should.not.have.property CONSTANT_DEFAULT_ROOT_ATTRIBUTE

    it 'strips the custom root attribute', ->
      json = new JsonLinker(model, 'customRoot')
        .links('author', 'tags')
        .toJson()
      unlinker = new JsonLinker(json, 'customRoot')
      actual = unlinker.toEmbeddedModel()
      actual.should.not.have.property 'customRoot'

    it 'returns model w/o links straight through', ->
      json = new JsonLinker(model, 'customRoot')
        .toJson()
      unlinker = new JsonLinker(json, 'customRoot')
      actual = unlinker.toEmbeddedModel()
      actual.should.eql model

    it 'strips the links attribute', ->
      actual = unlinker.toEmbeddedModel()
      actual.should.not.have.property 'links'

    it 'defaults to unlinking first non-linked, non-meta root attribute', ->
      json = new JsonLinker(model, 'anyNonLinkedNonMetaRoot')
        .links('author', 'tags')
        .toJson()
      unlinker = new JsonLinker(json)
      actual = unlinker.toEmbeddedModel()
      actual.should.eql model

    it 'lets models with errors pass through', ->
      json =
        errors: [{ id: 'terrible' }]
      unlinker = new JsonLinker(json)
      actual = unlinker.toEmbeddedModel()
      actual.should.eql json

    it 'lets empty object pass through', ->
      json = {}
      unlinker = new JsonLinker(json)
      actual = unlinker.toEmbeddedModel()
      actual.should.eql json

    it 'lets null pass through', ->
      json = null
      unlinker = new JsonLinker(json)
      actual = unlinker.toEmbeddedModel()
      should.not.exist actual

  # TODO: uncomment when we support array models well
#  describe '#first', ->
#
#    it 'returns the first model in the array', ->


  describe '#links (static)', ->

    it 'takes a model and properties', ->
      JsonLinker.links.length.should.eql 2

    it 'returns null if no model given', ->
      should.not.exist JsonLinker.links(null, 'someProp')

    it 'does no transform if property not found', ->
      JsonLinker.links(model, 'notFound').should.eql model

    it 'maintains other model fields',  ->
      actual = JsonLinker.links(model, 'tags')
      actual.should.have.property 'id', id

    it 'links singular properties', ->
      actual = JsonLinker.links(model, 'author')
      actual.links.should.have.property 'author', authorId
      actual.should.not.have.property 'author'

    it 'links plural properties', ->
      JsonLinker.links(model, 'tags').links.should.have.property 'tags', [ tagId1, tagId2 ]

    it 'links multiple properties at a time', ->
      actual = JsonLinker.links(model, 'tags', 'author')
      actual.links.should.have.property 'author', authorId
      actual.links.should.have.property 'tags', [ tagId1, tagId2 ]

    it 'is callable multiple times without modifying the model', ->
      id2 = 'always'
      dontMutate = [
        { id: id2, the: 'same' }
      ]
      model2 =
        toReplaceInOutputOnly: dontMutate
      actual = JsonLinker.links(model2, 'toReplaceInOutputOnly')
      actual.links.should.have.property 'toReplaceInOutputOnly', [ id2 ]
      model2.should.have.property 'toReplaceInOutputOnly', dontMutate

  describe '#unlinks (static)', ->

    linked = null

    beforeEach ->
      model = json.model[0]
      linked = _.clone json.linked

    it 'takes a model and a linked object', ->
      JsonLinker.unlinks.length.should.eql 2

    it 'returns null if no model given', ->
      should.not.exist JsonLinker.unlinks(null)

    it 'returns model if no linked object given', ->
      JsonLinker.unlinks(model).should.eql model

    it 'does no transform if json doesnt have links', ->
      delete model.links
      JsonLinker.unlinks(model, linked).should.eql model

    it 'errors if a link refs a non-existent linked', ->
      model.links.nonExistent = 'abc123'
      (-> JsonLinker.unlinks(model, linked)).should.throw(/Link with key \w+ doesn\'t exist in linked/)

    it 'strips the links attribute', ->
      JsonLinker.unlinks(model, linked).should.not.have.property 'links'

    it 'maintains other model fields',  ->
      actual = JsonLinker.unlinks(model, linked)
      actual.should.have.property 'id', id

    it 'unlinks singular properties', ->
      actual = JsonLinker.unlinks(model, linked)
      actual.should.have.property 'author', author

    it 'links plural properties', ->
      JsonLinker.unlinks(model, linked).should.have.property 'tags', tags

    it 'links only plural properties linked to', ->
      tagNotInLinks =
        id: 'dontFindMe'
        name: 'tagShouldNotBeInModel'
      linked.tags.push tagNotInLinks
      actual = JsonLinker.unlinks(model, linked)
      actual.should.have.property 'tags', tags

  describe '#linked (static)', ->

    it 'takes a model and properties', ->
      JsonLinker.linked.length.should.eql 2

    it 'returns null if no model given', ->
      should.not.exist JsonLinker.linked(null, 'someProp')

    it 'requires at least one property', ->
      (-> JsonLinker.linked(model)).should.throw()

    it 'does no transform if property not found', ->
      JsonLinker.linked(model, 'notFound').should.eql {}

    it 'adds singular properties to linked object', ->
      JsonLinker.linked(model, 'author').should.have.property 'author', author

    it 'adds plural properties to linked object', ->
      JsonLinker.linked(model, 'tags').should.have.property 'tags', tags

    it 'adds multiple properties at a time to linked object', ->
      actual = JsonLinker.linked(model, 'tags', 'author')
      actual.should.have.property 'author', author
      actual.should.have.property 'tags', tags
