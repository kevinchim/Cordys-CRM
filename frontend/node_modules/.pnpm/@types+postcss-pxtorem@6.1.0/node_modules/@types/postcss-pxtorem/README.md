# Installation
> `npm install --save @types/postcss-pxtorem`

# Summary
This package contains type definitions for postcss-pxtorem (https://github.com/cuth/postcss-pxtorem#readme).

# Details
Files were exported from https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/postcss-pxtorem.
## [index.d.ts](https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/postcss-pxtorem/index.d.ts)
````ts
import { Input, PluginCreator } from "postcss";
declare namespace PostcssPxToRem {
    interface Options {
        rootValue?: number | ((input: Input) => number);
        unitPrecision?: number;
        propList?: string[];
        selectorBlackList?: Array<string | RegExp>;
        replace?: boolean;
        mediaQuery?: boolean;
        minPixelValue?: number;
        exclude?: string | RegExp | ((file: string) => boolean);
        unit?: string;
    }
}

declare var pxtorem: PluginCreator<PostcssPxToRem.Options>;

export = pxtorem;

````

### Additional Details
 * Last updated: Tue, 01 Oct 2024 15:37:23 GMT
 * Dependencies: [postcss](https://npmjs.com/package/postcss)

# Credits
These definitions were written by [Steven Bassett](https://github.com/bassettsj).
