import { takeLatest } from 'redux-saga'
import { fork } from 'redux-saga/effects'

import { searchAll } from './query'
import { fetchSchema } from './schema'
import { firstVertex } from './schema'
import { fetchVertex } from './schema'
import { fetchEdge } from './schema'
import { layoutComponents } from './schema'

export function* sagas() {
  yield [
    fork(takeLatest, 'SEARCH_ALL_SUBMIT', searchAll),
    fork(takeLatest, 'SCHEMA_FETCH', fetchSchema),
    fork(takeLatest, 'SCHEMA_TAP_VERTEX', firstVertex),
    fork(takeLatest, 'VERTEX_FETCH', fetchVertex),
    fork(takeLatest, 'EDGE_FETCH', fetchEdge),
  ];
}
