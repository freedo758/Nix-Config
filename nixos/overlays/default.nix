final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyFinal: pyPrev: {
      click-threading = pyPrev.click-threading.overridePythonAttrs (old: {
        doCheck = false;
      });
    })
  ];
}
