'use strict'

var _ = require('underscore')

var DEFAULT_ID_FIELD = 'id'
var DEFAULT_ROOT_ATTRIBUTE = 'model'

/**
 * Sets up links for json api.  See docs:
 * http://jsonapi.org/format/#document-top-level
 *
 * @class Json Linker
 */
var JsonLinker = function (model, rootAttr) {
  this._model = model
  this._rootAttr = rootAttr || DEFAULT_ROOT_ATTRIBUTE
  this._links = []
}

/**
 * Replaces embedded objects with links by id
 *
 * Assumes that the id field of embedded objects is named `id`
 *
 * @param {Strings} properties one or more properties to be linked
 * @returns {JsonLinker} for chaining
 */
JsonLinker.prototype.links = function (properties) {
  if (!Array.isArray(properties)) {
    properties = Array.prototype.slice.call(arguments)
  }

  this._links = this._links.concat(properties.map(function (prop) {
    return {
      id: DEFAULT_ID_FIELD,
      name: prop
    }
  }))
  return this
}

/**
 * Converts model data to json-api linked json
 *
 * @returns {Object} json
 */
JsonLinker.prototype.toJson = function () {
  var json = {}
  var linksNameFields = this._links.map(function (link) {
    return link.name
  })
  var linkingArgs = [ this._model ].concat(linksNameFields)

  var rootObjectWithLinks = JsonLinker.links.apply(this, linkingArgs)
  json[this._rootAttr] = [ rootObjectWithLinks ]

  if (rootObjectWithLinks.links && Object.keys(rootObjectWithLinks.links).length > 0) {
    json.linked = JsonLinker.linked.apply(this, linkingArgs)
  }

  return json
}
JsonLinker.prototype.toJSON = JsonLinker.prototype.toJson

var META_KEYS = ['linked', 'meta']
var getFirstNonMetaAttr = function (model) {
  return _.find(Object.keys(model), function (key) {
    return META_KEYS.indexOf(key) === -1
  })
}

JsonLinker.prototype._getBestRootAttr = function () {
  if (this._model.hasOwnProperty(this._rootAttr)) {
    return this._rootAttr
  } else {
    return getFirstNonMetaAttr(this._model)
  }
}

/**
 * Converts json to an embedded model
 *
 * @returns {Object} model
 */
JsonLinker.prototype.toEmbeddedModel = function () {
  if (!this._model) return

  if (_.isObject(this._model) && Object.keys(this._model).length === 0) return this._model

  var rootModel = this._model[this._getBestRootAttr()]

  if (!rootModel)
    throw new Error('Root attribute ' + this._rootAttr + ' not supported')

  return JsonLinker.unlinks(rootModel[0], this._model.linked)
}

/**
 * Replaces embedded objects with links by id
 *
 * Assumes that the id field of embedded objects is named `id`
 *
 * @method links
 * @param model with embedded objects
 * @param {Strings} properties one or more properties to be linked
 * @returns {Object} model copy with links instead of embedded objects
 */
JsonLinker.links = function (model, properties) {
  if (!model) return

  properties = Array.prototype.slice.call(arguments, 1)

  var modelCopy = _.clone(model)

  properties.forEach(function (property) {
    if (modelCopy[property]) {
      if (!modelCopy.links)
        modelCopy.links = {}

      if (Array.isArray(modelCopy[property])) {
        modelCopy.links[property] = modelCopy[property].map(function (obj) {
          return obj[DEFAULT_ID_FIELD]
        })
      } else {
        modelCopy.links[property] = modelCopy[property][DEFAULT_ID_FIELD]
      }

      delete modelCopy[property]
    }
  })

  return modelCopy
}

/**
 * Reinstates linked objects into the model
 *
 * @param model with links
 * @param {Object} linked map of linked objects
 * @returns {Object} model copy with embedded objects
 */
JsonLinker.unlinks = function (model, linked) {
  if (!model) return

  if (!linked) return model

  if (!model.hasOwnProperty('links'))
    return model

  var modelCopy = _.clone(model)

  Object.keys(modelCopy.links).forEach(function (property) {
    if (!linked.hasOwnProperty(property))
      throw new Error('Link with key ' + property + ' doesn\'t exist in linked')

    if (Array.isArray(modelCopy.links[property])) {
      modelCopy[property] = modelCopy.links[property].map(function (propertyId) {
        return _.find(linked[property], function (obj) {
          return obj[DEFAULT_ID_FIELD] === propertyId
        })
      })
    } else {
      modelCopy[property] = linked[property]
    }
  })

  delete modelCopy.links

  return modelCopy
}


/**
 * Puts embedded objects from the model in a hash
 *
 * @method linked
 * @param model with embedded objects
 * @param {Strings} properties one or more properties to be linked
 * @returns {Object} linked map
 */
JsonLinker.linked = function (model, properties) {
  if (!model) return

  properties = Array.prototype.slice.call(arguments, 1)

  if (properties.length === 0) throw new Error('Properties to linked are required')

  return _.pick(model, properties)
}

module.exports = JsonLinker