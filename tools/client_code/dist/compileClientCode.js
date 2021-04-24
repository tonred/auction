"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.parseSolidityFileArg = parseSolidityFileArg;

var _handlebars = _interopRequireDefault(require("handlebars"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const os = require('os');

const path = require('path');

const fs = require('fs');

const texts = {
  sourceFileNotFound(name) {
    return `Source file [${name}] not found.`;
  }

};
const ClientCodeLevel = {
  none: 'none',
  run: 'run',
  deploy: 'deploy'
};
const JSModule = {
  node: 'node',
  nodeNoDefault: 'nodeNoDefault',
  es: 'es',
  esNoDefault: 'esNoDefault'
};

function parseSolidityFileArg(fileArg, fileMustExists) {
  const parsed = parseFileArg(fileArg, '.sol', fileMustExists);
  return {
    dir: parsed.dir,
    name: {
      base: parsed.base,
      sol: parsed.name,
      tvc: `${parsed.base}.tvc`,
      code: `${parsed.base}.code`,
      abi: `${parsed.base}.abi.json`,
      package: `${parsed.base}Package`,
      result: `${parsed.base}.result`
    }
  };
}

function bindPathJoinTo(base, separator) {
  if (separator) {
    const sep = separator;
    return (...items) => {
      let path = base;
      items.forEach(x => path = join(path, x, sep));
      return path;
    };
  }

  return (...items) => {
    return items.length > 0 ? path.join(base, ...items) : base;
  };
}

function parseFileArg(fileArg, ext, fileMustExists) {
  if (os.platform() === 'darwin' && fileArg.startsWith('~/')) {
    fileArg = path.join(os.homedir(), fileArg.substr(2));
  }

  const filePath = path.resolve(fileArg);
  const dir = bindPathJoinTo(path.dirname(filePath));
  const base = path.basename(filePath, ext);
  const name = base.includes('.') ? base : `${base}${ext}`;
  const result = {
    dir,
    base,
    name
  };

  if (fileMustExists && !fs.existsSync(result.dir(name))) {
    console.error(texts.sourceFileNotFound(name));
    process.exit(1);
  }

  return result;
}

_handlebars.default.registerHelper('LB', () => '{');

_handlebars.default.registerHelper('RB', () => '}');

function compileTemplate(...pathItems) {
  const templatePath = path.resolve(__dirname, '..', ...pathItems);
  const templateText = fs.readFileSync(templatePath, {
    encoding: 'utf8'
  });
  return {
    build: _handlebars.default.compile(templateText, {
      noEscape: true
    })
  };
}

async function applyTemplate(template, context) {
  return template.build(context);
}

const jsContractTemplate = compileTemplate('js-templates', 'contract.js.hbs');
const JsClientCode = {
  name: 'JavaScript',
  shortName: 'js',

  getTemplateContext(fileArg, options) {
    const file = parseSolidityFileArg(fileArg, false);
    const {
      dir,
      name
    } = file;

    const readText = (name, encoding) => {
      if (!fs.existsSync(dir(name))) {
        throw new Error(`File not exists: ${name}`);
      }

      return fs.readFileSync(dir(name)).toString(encoding);
    };

    const imageBase64 = options.clientLevel === ClientCodeLevel.deploy ? readText(name.tvc, 'base64') : '';
    const abiJson = readText(name.abi, 'utf8').trimRight();
    const abi = {
      functions: [],
      data: [],
      ...JSON.parse(abiJson)
    };
    const className = `${name.base[0].toUpperCase()}${name.base.substr(1)}Contract`;
    const isDeploy = (options.clientLevel || 'deploy') === 'deploy';

    const varContext = v => {
      const jsType = {
        address: 'string',
        'address[]': 'string[]',
        uint256: 'string',
        uint32: 'number',
        uint16: 'number',
        uint8: 'number',
        'uint256[]': 'string[]',
        'uint32[]': 'number[]',
        'uint16[]': 'number[]',
        'uint8[]': 'number[]'
      }[v.type] || v.type;
      return { ...v,
        jsType,
        isSameJsType: jsType === v.type
      };
    };

    const funContext = f => {
      return { ...f,
        hasData: false,
        hasInputsAndData: false,
        hasInputs: f.inputs.length > 0,
        hasOutputs: f.outputs.length > 0,
        inputs: f.inputs.map(varContext),
        outputs: f.outputs.map(varContext)
      };
    };

    const constructor = funContext(abi.functions.find(x => x.name === 'constructor') || {
      name: 'constructor',
      inputs: [],
      outputs: [],
      data: []
    });
    constructor.hasData = abi.data.length > 0;
    constructor.hasInputsAndData = constructor.hasInputs && constructor.hasData;
    constructor.data = abi.data.map(varContext);
    const functions = abi.functions.filter(x => x.name !== 'constructor').map(funContext);
    return {
      imageBase64,
      abiJson,
      abi,
      className,
      isDeploy,
      constructor,
      functions,
      jsModuleNode: options.jsModule === JSModule.node || options.jsModule === JSModule.nodeNoDefault,
      jsModuleNodeDefault: options.jsModule === JSModule.node,
      jsModuleEs: options.jsModule === JSModule.es || options.jsModule === JSModule.esNoDefault,
      jsModuleEsDefault: options.jsModule === JSModule.es
    };
  },

  async generate(files, options) {
    for (const file of files) {
      const {
        dir,
        base
      } = parseFileArg(file, '.sol', false);
      const js = await applyTemplate(jsContractTemplate, JsClientCode.getTemplateContext(file, options));
      fs.writeFileSync(dir(`${base}Contract.js`), js, {
        encoding: 'utf8'
      });
    }
  }

};
JsClientCode.generate([process.argv[2]], {
  clientLanguages: ['js'],
  clientLevel: ClientCodeLevel.deploy,
  jsModule: JSModule.es
});