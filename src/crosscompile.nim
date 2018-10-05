import strutils, strformat, os, ospaths, osproc, times, uri, zip/zipfiles

const
  temp_folder* = getTempDir() / "hackpad"       ## Temporary folder used for temporary files at runtime, etc.
  strip_cmd*  = "strip --verbose --strip-all"   ## Linux Bash command to strip the compiled binary executables.
  windows_args* = "--gcc.exe:/usr/bin/x86_64-w64-mingw32-gcc --gcc.linkerexe:/usr/bin/x86_64-w64-mingw32-gcc"  ## Windows Bash command line extra parameters for CrossCompilation on demand, for target Windows.
  android_args* = "--gcc.exe:/opt/android-ndk/toolchains/x86_64-4.9/prebuilt/linux-x86_64/bin/x86_64-linux-android-gcc --gcc.linkerexe:/opt/android-ndk/toolchains/x86_64-4.9/prebuilt/linux-x86_64/bin/x86_64-linux-android-gcc" ## Android Bash command line extra parameters for CrossCompilation on demand, for target Android.
createDir(temp_folder)
type CompileResult* = tuple[
  win, winzip, winsha, lin, linzip, linsha, doc, doczip, logs,
  jsf, jszip, jssha, andr, andrzip, andrsha: string] ## Tuple with full path string to binaries and SHA1 Sum of binaries.


# TODO:   (all boolean parameters)
# Enable/Disable Compilation for windows/linux/android/javascript
# Enable/Disable Documentation
# Enable/Disable ZIP
# Enable/Disable Strip
# Replace linux sha1sum with a Nim function


proc crosscompile*(code, target, opt, release, gc, app, ssls, threads: string): CompileResult =
  ## Receives code as string and crosscompiles and generates HTML Docs, Strips and ZIPs.
  var win, winzip, winsha, lin, linzip, linsha, doc, doczip, logs, jsf, jszip, jssha, andr, andrzip, andrsha: string
  if countLines(code.strip) >= 1:
    let
      temp_file_nim = temp_folder / "hackpad" & $epochTime().int & ".nim"
      temp_file_bin = temp_file_nim.replace(".nim", ".bin")  # .bin is not really needed, but some browsers complain of no file extension.
      temp_file_exe = temp_file_nim.replace(".nim", ".exe")
      temp_file_html = temp_file_nim.replace(".nim", ".html")
      temp_file_js = temp_file_nim.replace(".nim", ".js")
      temp_file_andr = temp_file_nim.replace(".nim", ".android.bin")
    writeFile(temp_file_nim,  code)
    var
      output: string
      exitCode: int
    # Linux Compilation.
    (output, exitCode) = execCmdEx(fmt"nim {target} {release} {opt} {gc} {app} {ssls} {threads} --out:{temp_file_bin} {temp_file_nim}")
    logs &= output
    if exitCode == 0:
      (output, exitCode) = execCmdEx(fmt"{strip_cmd} {temp_file_bin}")
      logs &= output
      if exitCode == 0:
        lin = splitPath(temp_file_bin).tail
        (output, exitCode) = execCmdEx(fmt"sha1sum {temp_file_bin}")
        logs &= output
        if exitCode == 0:
          linsha = output
          var z: ZipArchive
          discard z.open(temp_file_bin & ".zip", fmWrite)
          z.addFile(temp_file_bin)
          z.close
          linzip = splitPath(temp_file_bin & ".zip").tail
    # Windows Compilation.
    (output, exitCode) = execCmdEx(fmt"nim {target} {release} {opt} {gc} {app} {ssls} {threads} --cpu:amd64 --os:windows {windows_args} --out:{temp_file_exe} {temp_file_nim}")
    logs &= output
    if exitCode == 0:
      (output, exitCode) = execCmdEx(fmt"{strip_cmd} {temp_file_exe}")
      logs &= output
      if exitCode == 0:
        win = splitPath(temp_file_exe).tail
        (output, exitCode) = execCmdEx(fmt"sha1sum {temp_file_exe}")
        logs &= output
        if exitCode == 0:
          winsha = output
          var z: ZipArchive
          discard z.open(temp_file_exe & ".zip", fmWrite)
          z.addFile(temp_file_exe)
          z.close
          winzip = splitPath(temp_file_exe & ".zip").tail
    # JavaScript Compilation.
    (output, exitCode) = execCmdEx(fmt"nim js -d:nodejs {release} {opt} --out:{temp_file_js} {temp_file_nim}")
    logs &= output
    if exitCode == 0:
      jsf = splitPath(temp_file_js).tail
      (output, exitCode) = execCmdEx(fmt"sha1sum {temp_file_js}")
      logs &= output
      if exitCode == 0:
        jssha = output
        var z: ZipArchive
        discard z.open(temp_file_js & ".zip", fmWrite)
        z.addFile(temp_file_js)
        z.close
        jszip = splitPath(temp_file_js & ".zip").tail
    # Android Compilation.
    (output, exitCode) = execCmdEx(fmt"nim c --os:android {release} {opt} {android_args} --out:{temp_file_andr} {temp_file_nim}")
    logs &= output
    if exitCode == 0:
      (output, exitCode) = execCmdEx(fmt"{strip_cmd} {temp_file_andr}")
      logs &= output
      if exitCode == 0:
        andr = splitPath(temp_file_andr).tail
        (output, exitCode) = execCmdEx(fmt"sha1sum {temp_file_andr}")
        logs &= output
        if exitCode == 0:
          andrsha = output
          var z: ZipArchive
          discard z.open(temp_file_andr & ".zip", fmWrite)
          z.addFile(temp_file_andr)
          z.close
          andrzip = splitPath(temp_file_andr & ".zip").tail
    # HTML Docs Generation.
    (output, exitCode) = execCmdEx(fmt"nim doc --out:{temp_file_html} {temp_file_nim}")
    logs &= output
    if exitCode == 0:
      doc = splitPath(temp_file_html).tail
      var z: ZipArchive
      discard z.open(temp_file_html & ".zip", fmWrite)
      z.addFile(temp_file_html)
      z.close
      doczip = splitPath(temp_file_html & ".zip").tail
  let resultaditos: CompileResult = (
    win: win, winzip: winzip, winsha: winsha.strip, lin: lin, linzip: linzip,
    linsha: linsha.strip, doc: doc, doczip: doczip, logs: logs, jsf: jsf,
    jszip: jszip, jssha: jssha, andr: andr, andrzip: andrzip, andrsha: andrsha)
  result = resultaditos
