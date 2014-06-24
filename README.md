## json-linker

Provides linking compatible with [jsonapi](http://jsonapi.org/).

### Usage Example

#### Linking for json serialization

```js
// currently works only with singular models
var song = {
  title: 'Sunshine of Your Love'
  riffs: [
    { id: 'abc123', start: '1:04', stop: '1:20' },
    { id: 'qwe234', start: '2:34', stop: '2:59' }
  ],
  tags: [
    { id: 'w00t', name: 'creamy' },
    { id: '4r33l', name: 'awesome' }
  ]
}

var JsonLinker = require('json-linker')

var json = new JsonLinker(song, 'songs')
  .links('riffs', 'tags')
  .toJson()

// outputs =>
//
// {
//   songs: [{
//     title: 'Sunshine of Your Love',
//     links: {
//       riffs: ['abc123', 'qwe234'],
//       tags: ['w00t', '4r33l']
//     }
//   }],
//   linked: {
//     riffs: [
//       { id: 'abc123', start: '1:04', stop: '1:20' },
//       { id: 'qwe234', start: '2:34', stop: '2:59' }
//     ],
//     tags: [
//       { id: 'w00t', name: 'creamy' },
//       { id: '4r33l', name: 'awesome' }
//     ]
//   }
// }
```

#### Unlinking for embedded models

```js
// currently works only with singular models
var json = {
  songs: [{
    title: 'Sunshine of Your Love',
    links: {
      riffs: ['abc123', 'qwe234'],
      tags: ['w00t', '4r33l']
    }
  }],
  linked: {
    riffs: [
      { id: 'abc123', start: '1:04', stop: '1:20' },
      { id: 'qwe234', start: '2:34', stop: '2:59' }
    ],
    tags: [
      { id: 'w00t', name: 'creamy' },
      { id: '4r33l', name: 'awesome' }
    ]
  }
}

var JsonLinker = require('json-linker')

var model = new JsonLinker(song)
  .toEmbeddedModel()
  
// outputs =>
// var song = {
//   title: 'Sunshine of Your Love'
//   riffs: [
//     { id: 'abc123', start: '1:04', stop: '1:20' },
//     { id: 'qwe234', start: '2:34', stop: '2:59' }
//   ],
//   tags: [
//     { id: 'w00t', name: 'creamy' },
//     { id: '4r33l', name: 'awesome' }
//   ]
// }

```