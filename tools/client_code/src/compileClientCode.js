import Handlebars from 'handlebars';

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
    esNoDefault: 'esNoDefault',
};

export type ClientCodeLanguageType = string;

export type ClientCodeLevelType = $Keys<typeof ClientCodeLevel>;

export type ClientCodeOptions = {
    clientLanguages: ClientCodeLanguageType[],
    clientLevel: ClientCodeLevelType,
    jsModule: JSModuleType,
};

export type JSModuleType = $Keys<typeof JSModule>;

export type FileArg = {
    dir: PathJoin,
    base: string,
    name: string
}
export type PathJoin = (...items: string[]) => string;

export type SolidityFileArg = {
    dir: PathJoin,
    name: {
        base: string,
        sol: string,
        tvc: string,
        code: string,
        abi: string,
        package: string,
        result: string,
    },
}

export function parseSolidityFileArg(fileArg: string, fileMustExists: boolean): SolidityFileArg {
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
            result: `${parsed.base}.result`,
        },
    };
}

function bindPathJoinTo(base: string, separator?: string): PathJoin {
    if (separator) {
        const sep = separator;
        return (...items: string[]): string => {
            let path = base;
            items.forEach(x => path = join(path, x, sep));
            return path;
        }
    }
    return (...items: string[]): string => {
        return items.length > 0 ? path.join(base, ...items) : base;
    }
}

function parseFileArg(fileArg: string, ext: string, fileMustExists: boolean): FileArg {
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

Handlebars.registerHelper('LB', () => '{');
Handlebars.registerHelper('RB', () => '}');

function compileTemplate(...pathItems: string[]): Template {
    const templatePath = path.resolve(__dirname, '..', ...pathItems);
    const templateText = fs.readFileSync(templatePath, {encoding: 'utf8'});
    return {
        build: Handlebars.compile(templateText, {
            noEscape: true,
        })
    };
}

async function applyTemplate(template: Template, context: any): Promise<string> {
    return template.build(context);
}

const jsContractTemplate = compileTemplate('js-templates', 'contract.js.hbs');

const JsClientCode = {
    name: 'JavaScript',
    shortName: 'js',
    getTemplateContext(fileArg: string, options: ClientCodeOptions): any {
        const file = parseSolidityFileArg(fileArg, false);
        const {dir, name} = file;
        const readText = (name: string, encoding: 'utf8' | 'base64'): string => {
            if (!fs.existsSync(dir(name))) {
                throw new Error(`File not exists: ${name}`);
            }
            return fs.readFileSync(dir(name)).toString(encoding);
        };

        const imageBase64 = options.clientLevel === ClientCodeLevel.deploy
            ? readText(name.tvc, 'base64')
            : '';
        const abiJson = readText(name.abi, 'utf8').trimRight();
        const abi = {
            functions: [],
            data: [],
            ...JSON.parse(abiJson)
        };

        const className = `${name.base[0].toUpperCase()}${name.base.substr(1)}Contract`;
        const isDeploy = (options.clientLevel || 'deploy') === 'deploy';

        const varContext = (v) => {
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
                'uint8[]': 'number[]',
            }[v.type] || v.type;
            return {
                ...v,
                jsType,
                isSameJsType: jsType === v.type,
            }
        };

        const funContext = (f) => {
            return {
                ...f,
                hasData: false,
                hasInputsAndData: false,
                hasInputs: f.inputs.length > 0,
                hasOutputs: f.outputs.length > 0,
                inputs: f.inputs.map(varContext),
                outputs: f.outputs.map(varContext),
            }
        };

        const constructor = funContext(abi.functions.find(x => x.name === 'constructor') || {
            name: 'constructor',
            inputs: [],
            outputs: [],
            data: [],
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
            jsModuleEsDefault: options.jsModule === JSModule.es,
        };
    },
    async generate(files: string[], options: ClientCodeOptions) {
        for (const file of files) {
            const {dir, base} = parseFileArg(file, '.sol', false);
            const js = await applyTemplate(jsContractTemplate, JsClientCode.getTemplateContext(file, options));
            fs.writeFileSync(dir(`${base}Contract.js`), js, {encoding: 'utf8'});
        }
    }
};

JsClientCode.generate([process.argv[2]], {
    clientLanguages: ['js'],
    clientLevel: ClientCodeLevel.deploy,
    jsModule: JSModule.es,
})
