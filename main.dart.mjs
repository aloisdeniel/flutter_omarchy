// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            AB: (decoder, codeUnits) => decoder.decode(codeUnits),
      AC: o => o.byteOffset,
      AD: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      AE: (x0,x1) => x0.appendChild(x1),
      AF: (x0,x1) => x0.removeAttribute(x1),
      AG: x0 => x0.offsetX,
      AH: x0 => x0.clientHeight,
      AI: x0 => x0.deref(),
      AJ: x0 => x0.send(),
      AK: x0 => x0.head,
      B: s => printToConsole(s),
      BB: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      BC: o => o.buffer,
      BD: x0 => x0.state,
      BE: x0 => x0.debugShowSemanticsNodes,
      BF: x0 => x0.isConnected,
      BG: x0 => x0.type,
      BH: x0 => x0.innerWidth,
      BI: () => globalThis.WeakRef,
      BJ: (x0,x1) => x0.revokeObjectURL(x1),
      BK: (x0,x1,x2) => x0.insertBefore(x1,x2),
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: () => new TextDecoder("utf-8", {fatal: true}),
      CC: (b, o) => new DataView(b, o),
      CD: x0 => x0.hash,
      CE: (o, c) => o instanceof c,
      CF: x0 => x0.click(),
      CG: x0 => x0.hasFocus(),
      CH: x0 => x0.width,
      CI: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      CJ: (x0,x1) => { x0.src = x1 },
      CK: x0 => x0.id,
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: () => new TextDecoder("utf-8", {fatal: false}),
      DC: (b, o, l) => new DataView(b, o, l),
      DD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      DE: x0 => x0.vendor,
      DF: (x0,x1) => x0.getElementsByClassName(x1),
      DG: x0 => x0.shiftKey,
      DH: x0 => x0.clientWidth,
      DI: (a, s, e) => a.slice(s, e),
      DJ: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      DK: x0 => x0.offsetHeight,
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: s => s.trimLeft(),
      EC: Function.prototype.call.bind(DataView.prototype.getUint8),
      ED: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      EE: (x0,x1) => x0.createTextNode(x1),
      EF: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      EG: x0 => x0.visibilityState,
      EH: (x0,x1) => x0.removeChild(x1),
      EI: x0 => ({type: x0}),
      EJ: x0 => x0.naturalHeight,
      EK: x0 => x0.offsetWidth,
      F: () => new Error().stack,
      FB: (l, r) => l === r,
      FC: Function.prototype.call.bind(DataView.prototype.setUint8),
      FD: x0 => x0.state,
      FE: (x0,x1) => { x0.nonce = x1 },
      FF: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      FG: x0 => x0.disconnect(),
      FH: x0 => x0.firstChild,
      FI: (x0,x1) => new Blob(x0,x1),
      FJ: x0 => x0.naturalWidth,
      FK: x0 => x0.stopPropagation(),
      G: s => JSON.stringify(s),
      GB: s => s.toUpperCase(),
      GC: Function.prototype.call.bind(DataView.prototype.getFloat64),
      GD: (x0,x1,x2) => x0.addEventListener(x1,x2),
      GE: x0 => x0.nonce,
      GF: (x0,x1) => x0.contains(x1),
      GG: x0 => new Intl.Locale(x0),
      GH: x0 => x0.viewConstraints,
      GI: x0 => new ClipboardItem(x0),
      GJ: x0 => x0.decode(),
      GK: x0 => x0.disabled,
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: Object.is,
      HC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      HD: (x0,x1) => x0.go(x1),
      HE: () => globalThis.window.flutterConfiguration,
      HF: (s) => +s,
      HG: x0 => x0.region,
      HH: x0 => x0.hostElement,
      HI: (x0,x1) => x0.write(x1),
      HJ: (x0,x1) => { x0.decoding = x1 },
      HK: (x0,x1) => { x0.min = x1 },
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: (x0,x1) => x0.test(x1),
      IC: (t, s) => t.set(s),
      ID: (x0,x1) => x0.append(x1),
      IE: (x0,x1) => x0.attachShadow(x1),
      IF: x0 => x0.target,
      IG: x0 => x0.script,
      IH: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      II: x0 => x0.clipboard,
      IJ: (x0,x1) => { x0.crossOrigin = x1 },
      IK: (x0,x1) => { x0.max = x1 },
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: (a, i, v) => a[i] = v,
      JC: Function.prototype.call.bind(DataView.prototype.setFloat32),
      JD: (x0,x1) => { x0.textContent = x1 },
      JE: x0 => x0.preventDefault(),
      JF: (x0,x1) => x0.dispatchEvent(x1),
      JG: x0 => x0.language,
      JH: x0 => ({runApp: x0}),
      JI: x0 => x0.navigator,
      JJ: (x0,x1) => x0.createObjectURL(x1),
      JK: (x0,x1) => { x0.disabled = x1 },
      K: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      KB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      KC: Function.prototype.call.bind(DataView.prototype.getFloat32),
      KD: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      KE: (x0,x1) => x0.contains(x1),
      KF: (x0,x1) => x0.createEvent(x1),
      KG: x0 => x0.languages,
      KH: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      KI: (o, p, v) => o[p] = v,
      KJ: x0 => x0.URL,
      KK: (x0,x1) => { x0.scrollLeft = x1 },
      L: o => o === undefined,
      LB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      LC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      LD: x0 => x0.parentElement,
      LE: (x0,x1) => x0.focus(x1),
      LF: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      LG: (x0,x1) => x0.observe(x1),
      LH: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      LI: x0 => x0.isSecureContext,
      LJ: x0 => new Blob(x0),
      LK: (x0,x1) => { x0.spellcheck = x1 },
      M: o => String(o),
      MB: Function.prototype.call.bind(String.prototype.toLowerCase),
      MC: Function.prototype.call.bind(DataView.prototype.getUint32),
      MD: (x0,x1) => x0.querySelectorAll(x1),
      ME: (x0,x1) => x0.closest(x1),
      MF: () => globalThis.window,
      MG: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      MH: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      MI: () => globalThis.window,
      MJ: x0 => x0.close(),
      MK: (x0,x1) => { x0.disabled = x1 },
      N: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      NB: (o, p, r) => o.replace(p, () => r),
      NC: Function.prototype.call.bind(DataView.prototype.setUint32),
      ND: x0 => x0.length,
      NE: (x0,x1) => x0.getAttribute(x1),
      NF: x0 => x0.readText(),
      NG: x0 => new ResizeObserver(x0),
      NH: () => typeof dartUseDateNowForTicks !== "undefined",
      NI: (x0,x1,x2,x3) => x0.putImageData(x1,x2,x3),
      NJ: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      NK: x0 => x0.canvasKitMaximumSurfaces,
      O: (x0,x1) => x0.didCreateEngineInitializer(x1),
      OB: (o, p, r) => o.replaceAll(p, () => r),
      OC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      OD: (x0,x1) => x0.item(x1),
      OE: x0 => x0.activeElement,
      OF: x0 => x0.clipboard,
      OG: x0 => globalThis.parseFloat(x0),
      OH: () => Date.now(),
      OI: x0 => x0.arrayBuffer(),
      OJ: (x0,x1) => x0.decode(x1),
      OK: x0 => x0.nextSibling,
      P: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PB: (x0,x1) => x0[x1],
      PC: Function.prototype.call.bind(DataView.prototype.getInt32),
      PD: x0 => x0.userAgent,
      PE: (x0,x1) => x0.add(x1),
      PF: (x0,x1) => x0.writeText(x1),
      PG: (x0,x1) => x0.getComputedStyle(x1),
      PH: () => 1000 * performance.now(),
      PI: (x0,x1) => x0.transferFromImageBitmap(x1),
      PJ: x0 => x0.duration,
      PK: (x0,x1) => x0.debug(x1),
      Q: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      QB: x0 => x0.index,
      QC: Function.prototype.call.bind(DataView.prototype.setInt32),
      QD: x0 => x0.maxTouchPoints,
      QE: x0 => x0.classList,
      QF: x0 => x0.unlock(),
      QG: x0 => x0.documentElement,
      QH: x0 => new Uint8Array(x0),
      QI: x0 => x0.height,
      QJ: x0 => x0.image,
      QK: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      R: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      RB: x0 => x0.pop(),
      RC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      RD: x0 => x0.platform,
      RE: x0 => x0.data,
      RF: (x0,x1) => x0.lock(x1),
      RG: x0 => x0.computedStyleMap(),
      RH: (x0,x1,x2) => x0.slice(x1,x2),
      RI: x0 => x0.width,
      RJ: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      RK: x0 => x0.hostElement,
      S: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      SB: x0 => x0.flags,
      SC: o => o instanceof Uint16Array,
      SD: x0 => x0.navigator,
      SE: x0 => x0.scrollTop,
      SF: x0 => x0.orientation,
      SG: (x0,x1) => x0.get(x1),
      SH: (x0,x1) => x0.decode(x1),
      SI: x0 => x0.rasterEndMilliseconds,
      SJ: x0 => new window.ImageDecoder(x0),
      SK: x0 => x0.location,
      T: x0 => new Promise(x0),
      TB: s => s.trim(),
      TC: Function.prototype.call.bind(DataView.prototype.getUint16),
      TD: s => new Date(s * 1000).getTimezoneOffset() * 60,
      TE: (handle) => clearTimeout(handle),
      TF: (x0,x1) => x0.querySelector(x1),
      TG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      TH: (x0,x1) => x0.adoptText(x1),
      TI: x0 => x0.rasterStartMilliseconds,
      TJ: x0 => x0.name,
      TK: (x0,x1) => x0.getModifierState(x1),
      U: (x0,x1,x2) => x0.call(x1,x2),
      UB: (a, s) => a.join(s),
      UC: Function.prototype.call.bind(DataView.prototype.setUint16),
      UD: Date.now,
      UE: (x0,x1) => { x0.scrollTop = x1 },
      UF: (x0,x1) => { x0.content = x1 },
      UG: x0 => x0.matches,
      UH: x0 => x0.first(),
      UI: x0 => x0.imageBitmaps,
      UJ: x0 => x0.repetitionCount,
      UK: x0 => x0.metaKey,
      V: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      VB: x0 => x0.random(),
      VC: o => o instanceof Int16Array,
      VD: (x0,x1,x2) => x0.setAttribute(x1,x2),
      VE: x0 => x0.tagName,
      VF: x0 => x0.head,
      VG: (x0,x1) => x0.matchMedia(x1),
      VH: x0 => x0.next(),
      VI: (x0,x1) => { x0.height = x1 },
      VJ: x0 => x0.frameCount,
      VK: x0 => x0.altKey,
      W: x0 => new Array(x0),
      WB: () => globalThis.Math,
      WC: Function.prototype.call.bind(DataView.prototype.getInt16),
      WD: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      WE: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      WF: (x0,x1) => { x0.name = x1 },
      WG: x0 => x0.matches,
      WH: x0 => x0.current(),
      WI: (x0,x1) => { x0.width = x1 },
      WJ: x0 => x0.selectedTrack,
      WK: x0 => x0.ctrlKey,
      X: o => [o],
      XB: (x0,x1) => x0.error(x1),
      XC: Function.prototype.call.bind(DataView.prototype.setInt16),
      XD: x0 => x0.style,
      XE: (x0,x1) => { x0.value = x1 },
      XF: (x0,x1) => { x0.title = x1 },
      XG: x0 => x0.timeStamp,
      XH: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      XI: x0 => x0.convertToBlob(),
      XJ: x0 => x0.completed,
      XK: x0 => x0.isComposing,
      Y: (o0, o1) => [o0, o1],
      YB: () => globalThis.console,
      YC: o => o instanceof Uint8ClampedArray,
      YD: (x0,x1) => x0.createElement(x1),
      YE: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      YF: () => globalThis.document,
      YG: (x0,x1) => x0.hasAttribute(x1),
      YH: x0 => x0.v8BreakIterator,
      YI: (x0,x1,x2) => new ImageData(x0,x1,x2),
      YJ: x0 => x0.ready,
      YK: x0 => x0.code,
      Z: (o0, o1, o2) => [o0, o1, o2],
      ZB: s => s.trimRight(),
      ZC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      ZD: x0 => x0.body,
      ZE: (x0,x1) => { x0.value = x1 },
      ZF: (x0,x1) => x0.vibrate(x1),
      ZG: x0 => x0.buttons,
      ZH: () => globalThis.Intl,
      ZI: (x0,x1) => x0.getContext(x1),
      ZJ: x0 => x0.tracks,
      ZK: x0 => x0.repeat,
      a: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      aB: (a, i) => a.push(i),
      aC: Function.prototype.call.bind(DataView.prototype.setInt8),
      aD: x0 => x0.remove(),
      aE: x0 => x0.relatedTarget,
      aF: (o, p) => p in o,
      aG: x0 => x0.ctrlKey,
      aH: (x0,x1) => x0.segment(x1),
      aI: (x0,x1) => new OffscreenCanvas(x0,x1),
      aJ: () => globalThis.window.ImageDecoder,
      aK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      b: (x0,x1,x2) => { x0[x1] = x2 },
      bB: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      bC: Function.prototype.call.bind(DataView.prototype.getInt8),
      bD: (x0,x1) => x0.getPropertyValue(x1),
      bE: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      bF: x0 => x0.arrayBuffer(),
      bG: x0 => x0.y,
      bH: x0 => x0.index,
      bI: x0 => x0.allocationSize(),
      bJ: x0 => x0.status,
      bK: x0 => x0.userAgent,
      c: o => o,
      cB: () => ({}),
      cC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      cD: (x0,x1) => x0.warn(x1),
      cE: x0 => x0.value,
      cF: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      cG: x0 => x0.x,
      cH: x0 => x0.next(),
      cI: (x0,x1) => x0.copyTo(x1),
      cJ: x0 => x0.response,
      cK: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      d: (o, p) => o[p],
      dB: (o, p, v) => o[p] = v,
      dC: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      dD: x0 => x0.console,
      dE: x0 => x0.selectionDirection,
      dF: x0 => x0.status,
      dG: x0 => x0.offsetTop,
      dH: x0 => x0.value,
      dI: (x0,x1) => { x0.height = x1 },
      dJ: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      dK: x0 => x0.length,
      e: () => globalThis,
      eB: () => [],
      eC: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      eD: (x0,x1) => { x0.id = x1 },
      eE: x0 => x0.selectionStart,
      eF: (x0,x1) => x0.fetch(x1),
      eG: x0 => x0.scrollLeft,
      eH: x0 => x0.done,
      eI: (x0,x1) => { x0.width = x1 },
      eJ: (x0,x1) => { x0.responseType = x1 },
      eK: x0 => x0.getReader(),
      f: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fB: b => !!b,
      fC: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      fD: (x0,x1) => x0.requestAnimationFrame(x1),
      fE: x0 => x0.selectionEnd,
      fF: x0 => x0.content,
      fG: x0 => x0.offsetLeft,
      fH: (o, m, a) => o[m].apply(o, a),
      fI: (x0,x1) => x0.toDataURL(x1),
      fJ: () => new XMLHttpRequest(),
      fK: x0 => x0.value,
      g: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gB: x0 => new Int8Array(x0),
      gC: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      gD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gE: x0 => x0.value,
      gF: x0 => x0.document,
      gG: x0 => x0.offsetParent,
      gH: x0 => x0.iterator,
      gI: (x0,x1,x2,x3) => x0.drawImage(x1,x2,x3),
      gJ: x0 => x0.input,
      gK: x0 => x0.done,
      h: (x0,x1) => ({addView: x0,removeView: x1}),
      hB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      hC: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      hD: x0 => x0.now(),
      hE: x0 => x0.selectionDirection,
      hF: x0 => x0.language,
      hG: x0 => x0.deltaMode,
      hH: () => globalThis.Symbol,
      hI: (x0,x1) => x0.getContext(x1),
      hJ: (o, p) => p in o,
      hK: x0 => x0.read(),
      i: (x0,x1) => x0.exec(x1),
      iB: x0 => new Uint8Array(x0),
      iC: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      iD: x0 => x0.performance,
      iE: x0 => x0.selectionStart,
      iF: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      iG: x0 => x0.deltaY,
      iH: (x0,x1) => new Intl.Segmenter(x0,x1),
      iI: x0 => x0.displayHeight,
      iJ: x0 => x0.groups,
      iK: x0 => x0.body,
      j: x0 => x0.length,
      jB: x0 => new Uint8ClampedArray(x0),
      jC: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      jD: (x0,x1) => x0.unregister(x1),
      jE: x0 => x0.selectionEnd,
      jF: (x0,x1) => x0.prepend(x1),
      jG: x0 => x0.deltaX,
      jH: x0 => x0.Segmenter,
      jI: x0 => x0.format,
      jJ: (x0,x1) => x0.append(x1),
      jK: x0 => x0.assetBase,
      k: o => o,
      kB: x0 => new Int16Array(x0),
      kC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      kD: () => globalThis.window.FinalizationRegistry,
      kE: x0 => x0.keyCode,
      kF: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      kG: x0 => x0.wheelDeltaY,
      kH: x0 => x0.buffer,
      kI: x0 => x0.displayWidth,
      kJ: (x0,x1,x2) => x0.insertRule(x1,x2),
      kK: x0 => x0.loader,
      l: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      lB: x0 => new Uint16Array(x0),
      lC: x0 => x0.history,
      lD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      lE: (x0,x1) => x0.scrollIntoView(x1),
      lF: (x0,x1) => x0.querySelector(x1),
      lG: x0 => x0.wheelDeltaX,
      lH: x0 => x0.wasmMemory,
      lI: x0 => x0.naturalHeight,
      lJ: (x0,x1) => x0.add(x1),
      lK: () => globalThis._flutter,
      m: (x0,x1) => { x0.lastIndex = x1 },
      mB: x0 => new Int32Array(x0),
      mC: x0 => x0.search,
      mD: x0 => new window.FinalizationRegistry(x0),
      mE: x0 => x0.multiViewEnabled,
      mF: (x0,x1) => x0.querySelectorAll(x1),
      mG: x0 => x0.key,
      mH: () => globalThis.window._flutter_skwasmInstance,
      mI: x0 => x0.naturalWidth,
      mJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      n: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      nB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      nC: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      nD: x0 => x0.scale,
      nE: x0 => x0.parent,
      nF: x0 => x0.tabIndex,
      nG: x0 => x0.identifier,
      nH: () => new TextDecoder(),
      nI: (x0,x1) => x0.createElement(x1),
      nJ: x0 => x0.preventDefault(),
      o: o => o instanceof RegExp,
      oB: x0 => new Uint32Array(x0),
      oC: x0 => x0.location,
      oD: x0 => x0.visualViewport,
      oE: (x0,x1) => x0.replaceWith(x1),
      oF: x0 => x0.parentNode,
      oG: x0 => x0.touches,
      oH: (a, i) => a.splice(i, 1),
      oI: (x0,x1) => { x0.pointerEvents = x1 },
      oJ: x0 => x0.createRange(),
      p: o => o,
      pB: x0 => new Float32Array(x0),
      pC: x0 => x0.pathname,
      pD: x0 => x0.devicePixelRatio,
      pE: (x0,x1) => { x0.type = x1 },
      pF: x0 => x0.clientY,
      pG: x0 => x0.pressure,
      pH: a => a.pop(),
      pI: (x0,x1) => { x0.height = x1 },
      pJ: (x0,x1) => x0.selectNode(x1),
      q: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      qB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      qC: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      qD: (d, digits) => d.toFixed(digits),
      qE: (x0,x1) => { x0.className = x1 },
      qF: x0 => x0.clientX,
      qG: x0 => x0.tiltY,
      qH: (map, o, v) => map.set(o, v),
      qI: (x0,x1) => { x0.width = x1 },
      qJ: x0 => x0.getSelection(),
      r: x0 => x0.dotAll,
      rB: x0 => new Float64Array(x0),
      rC: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      rD: x0 => x0.maxHeight,
      rE: (x0,x1) => { x0.tabIndex = x1 },
      rF: x0 => x0.getBoundingClientRect(),
      rG: x0 => x0.tiltX,
      rH: (map, o) => map.get(o),
      rI: x0 => x0.style,
      rJ: x0 => x0.removeAllRanges(),
      s: x0 => x0.unicode,
      sB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      sC: o => Object.keys(o),
      sD: x0 => x0.maxWidth,
      sE: (x0,x1) => { x0.name = x1 },
      sF: x0 => x0.bottom,
      sG: x0 => x0.pointerType,
      sH: () => new WeakMap(),
      sI: (x0,x1) => { x0.src = x1 },
      sJ: (x0,x1) => x0.addRange(x1),
      t: x0 => x0.ignoreCase,
      tB: x0 => new ArrayBuffer(x0),
      tC: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      tD: x0 => x0.minHeight,
      tE: (x0,x1) => { x0.placeholder = x1 },
      tF: x0 => x0.top,
      tG: x0 => x0.pointerId,
      tH: x0 => x0.debugSkipFontRetryDelay,
      tI: () => globalThis.document,
      tJ: () => globalThis.window,
      u: x0 => x0.multiline,
      uB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      uC: f => f.dartFunction,
      uD: x0 => x0.minWidth,
      uE: (x0,x1) => { x0.autocomplete = x1 },
      uF: x0 => x0.right,
      uG: x0 => x0.getCoalescedEvents(),
      uH: (x0,x1,x2) => x0.set(x1,x2),
      uI: x0 => x0.src,
      uJ: (x0,x1) => { x0.innerText = x1 },
      v: (string, token) => string.split(token),
      vB: (x0,x1,x2) => new DataView(x0,x1,x2),
      vC: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      vD: x0 => x0.height,
      vE: (x0,x1) => { x0.name = x1 },
      vF: x0 => x0.left,
      vG: (x0,x1) => x0.getModifierState(x1),
      vH: x0 => x0.fontFallbackBaseUrl,
      vI: x0 => x0.decode(),
      vJ: x0 => x0.offsetY,
      w: o => o instanceof Array,
      wB: (o, p) => o[p],
      wC: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      wD: x0 => x0.width,
      wE: (x0,x1) => { x0.placeholder = x1 },
      wF: x0 => x0.clientY,
      wG: x0 => x0.blur(),
      wH: (handle) => clearInterval(handle),
      wI: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      wJ: x0 => x0.offsetX,
      x: (a, i) => a[i],
      xB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      xC: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      xD: x0 => x0.screen,
      xE: (x0,x1) => { x0.action = x1 },
      xF: x0 => x0.clientX,
      xG: x0 => x0.button,
      xH: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      xI: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      xJ: x0 => x0.button,
      y: a => a.length,
      yB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      yC: (o, i) => o[i],
      yD: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      yE: (x0,x1) => { x0.method = x1 },
      yF: x0 => x0.changedTouches,
      yG: x0 => x0.innerHeight,
      yH: () => Date.now(),
      yI: (x0,x1,x2) => x0.addEventListener(x1,x2),
      yJ: x0 => x0.classList,
      z: (string, times) => string.repeat(times),
      zB: Function.prototype.call.bind(DataView.prototype.setFloat64),
      zC: o => o.length,
      zD: (x0,x1) => x0.removeProperty(x1),
      zE: (x0,x1) => { x0.noValidate = x1 },
      zF: x0 => x0.offsetY,
      zG: x0 => x0.height,
      zH: x0 => new WeakRef(x0),
      zI: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      zJ: x0 => x0.sheet,

    };

    const baseImports = {
      _: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
