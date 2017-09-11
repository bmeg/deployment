import { call, put, select } from 'redux-saga/effects'
import { push } from 'react-router-redux'
import * as _ from 'underscore'
import Facets from '../query/facets'

export function* fetchFacets(action) {
  const facets = yield call(Facets.fetchFacets);
  yield put({
    type: 'FACETS_SAVE',
    facets: facets
  })
}

export function* aggregateFacets(action) {
  // ES names do _not_ have `Type.` prefix, stip it out
  var queryString = (action.queryString || '*')
  var re = /(\w+).(\w+):/g
  queryString = queryString.replace(re, '$2:');
  const facets = yield call(Facets.aggregateFacets, queryString);
  // console.log('aggregatedFacets',aggregatedFacets);
  yield put({
    type: 'FACETS_SAVE',
    facets: facets,
  })
}

export function* selectFacet(action) {
  // console.log(action)
  yield put({...action, type: 'SELECTED_FACET'})
  // const state = yield select();
  // yield put({
  //   type: 'REFRESH_QUERY',
  //   label: action.facet.label,
  //   focus: action.facet.label,
  //   path: state.path,
  //   schema: state.schema,
  //   selectedFacets: state.selectedFacets,
  // })
}
