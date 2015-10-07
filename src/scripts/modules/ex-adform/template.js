import {fromJS} from 'immutable';
import {webalize} from '../../utils/string';

export default function (configName, baseConfig) {
  const template = fromJS({
    'parameters': {
      'api': {
        'baseUrl': 'https://api.adform.com/Services/',
        'authentication': {
          'type': 'token'
        },
        'pagination': {
          'method': 'response.url'
        },
        'name': 'adform'
      },
      'config': {
        'username': '',
        '#password': '',
        'auth': {
          'request': {
            'endpoint': 'Security/Login',
            'headers': {
              'Content-Type': 'application/json'
            },
            'body': {
              'UserName': {
                'attr': 'username'
              },
              'PassWord': {
                'attr': '#password'
              }
            }
          },
          'tokenKey': 'Ticket'
        }
      }
    }
  });

  return template
    .setIn(['parameters', 'config', 'id'], webalize(configName))
    .mergeDeep(baseConfig);
}

