'use strict'

/**
 * Sets up links for json api.  See docs:
 * http://jsonapi.org/format/#document-top-level
 *
 * @class Json Linker
 */

var _ = require('underscore')

// TODO: What about the case where the id of a linked object is multi-field? (concat in json, parse out in ctrl?)
var ID_FIELD = 'id'

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
exports.links = function (model, properties) {
  if (!model) return

  properties = Array.prototype.slice.call(arguments, 1)

  if (properties.length === 0) throw new Error('Properties to link are required')

  var modelCopy = _.clone(model)


  properties.forEach(function (property) {
    if (modelCopy[property]) {
      if (!modelCopy.links)
        modelCopy.links = {}

      if (Array.isArray(modelCopy[property])) {
        modelCopy.links[property] = modelCopy[property].map(function (obj) {
          return obj[ID_FIELD]
        })
      } else {
        modelCopy.links[property] = modelCopy[property][ID_FIELD]
      }

      delete modelCopy[property]
    }
  })

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
exports.linked = function (model, properties) {
  if (!model) return

  properties = Array.prototype.slice.call(arguments, 1)

  if (properties.length === 0) throw new Error('Properties to linked are required')

  return _.pick(model, properties)
}
