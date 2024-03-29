import Index from './react/Index';
import installedComponentsActions from '../components/InstalledComponentsActionCreators';
import HeaderButtons from './react/HeaderButtons';
import storageActions from '../components/StorageActionCreators';
import jobsActionCreators from '../jobs/ActionCreators';

const componentId = 'geneea-nlp-analysis';

export default {
  name: componentId,
  path: `${componentId}/:config`,
  isComponent: true,
  defaultRouteHandler: Index,
  headerButtonsHandler: HeaderButtons,
  requireData: [
    (params) => installedComponentsActions.loadComponentConfigData(componentId, params.config),
    () => storageActions.loadTables()
  ],
  poll: {
    interval: 5,
    action: (params) => jobsActionCreators.loadComponentConfigurationLatestJobs(componentId, params.config)
  }
};
