## json-linker

Provides linking compatible with [jsonapi](http://jsonapi.org/).

### Usage Example

```js
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

var linker = require('json-linker')

var json = {
  songs: [
    linker.links(song, 'riffs', 'tags')
  ],
  linked: linker.linked(model, 'riffs', 'tags')
}

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