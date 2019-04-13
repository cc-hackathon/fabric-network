import shim = require('fabric-shim');
import MrtgexchgChaincode from './MrtgexchgChaincode';

shim.start(new MrtgexchgChaincode());
