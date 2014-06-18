'use strict'

should = require 'should'

path = require '../util/path'
linker = require path.toApp('json-linker')

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

  model =
    id: id
    author: author
    tags: tags

  describe '#links', ->

    it 'takes a model and properties', ->
      linker.links.length.should.eql 2

    it 'returns null if no model given', ->
      should.not.exist linker.links(null, 'someProp')

    it 'requires at least one property', ->
      (-> linker.links(model)).should.throw()

    it 'does no transform if property not found', ->
      linker.links(model, 'notFound').should.eql model

    it 'maintains other model fields',  ->
      actual = linker.links(model, 'tags')
      actual.should.have.property 'id', id

    it 'links singular properties', ->
      actual = linker.links(model, 'author')
      actual.links.should.have.property 'author', authorId
      actual.should.not.have.property 'author'

    it 'links plural properties', ->
      linker.links(model, 'tags').links.should.have.property 'tags', [ tagId1, tagId2 ]

    it 'links multiple properties at a time', ->
      actual = linker.links(model, 'tags', 'author')
      actual.links.should.have.property 'author', authorId
      actual.links.should.have.property 'tags', [ tagId1, tagId2 ]

    it 'is callable multiple times without modifying the model', ->
      id2 = 'always'
      dontMutate = [
        { id: id2, the: 'same' }
      ]
      model2 =
        toReplaceInOutputOnly: dontMutate
      actual = linker.links(model2, 'toReplaceInOutputOnly')
      actual.links.should.have.property 'toReplaceInOutputOnly', [ id2 ]
      model2.should.have.property 'toReplaceInOutputOnly', dontMutate

  describe '#linked', ->

    it 'takes a model and properties', ->
      linker.linked.length.should.eql 2

    it 'returns null if no model given', ->
      should.not.exist linker.linked(null, 'someProp')

    it 'requires at least one property', ->
      (-> linker.linked(model)).should.throw()

    it 'does no transform if property not found', ->
      linker.linked(model, 'notFound').should.eql {}

    it 'adds singular properties to linked object', ->
      linker.linked(model, 'author').should.have.property 'author', author

    it 'adds plural properties to linked object', ->
      linker.linked(model, 'tags').should.have.property 'tags', tags

    it 'adds multiple properties at a time to linked object', ->
      actual = linker.linked(model, 'tags', 'author')
      actual.should.have.property 'author', author
      actual.should.have.property 'tags', tags
