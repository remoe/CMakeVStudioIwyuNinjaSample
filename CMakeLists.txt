
cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

function( create_vs_env )
    # Find Compiler
    set(PROGRAMFILES_X86 "ProgramFiles(x86)")
    set(VS_PATH32 "$ENV{${PROGRAMFILES_X86}}/Microsoft Visual Studio")
    file(TO_CMAKE_PATH "${VS_PATH32}" VS_PATH32)

    execute_process(
    COMMAND "${VS_PATH32}/Installer/vswhere.exe" -latest -prerelease -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    OUTPUT_VARIABLE VSWHERE_LATEST
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    set(DETECT_VS_VARS_FILE ${CMAKE_CURRENT_BINARY_DIR}/_detect_vs_vars.bat)
    set(DETECT_VS_VARS_RESULT_FILE ${CMAKE_CURRENT_BINARY_DIR}/_detect_vs_vars_result.txt)

    file(
        WRITE ${DETECT_VS_VARS_FILE}
        "@call \"${VSWHERE_LATEST}\\VC\\Auxiliary\\Build\\vcvarsall.bat\" x86_amd64\nset > ${DETECT_VS_VARS_RESULT_FILE}"
    )

    execute_process(
        COMMAND "${DETECT_VS_VARS_FILE}"
        ERROR_QUIET
    )

    set(VSVARS_TO_DETECT
        INCLUDE
        LIB
        LIBPATH
        Path
        Platform
        PROCESSOR_ARCHITECTURE
        PROCESSOR_IDENTIFIER
        PROCESSOR_LEVEL
        PROCESSOR_REVISION
        UCRTVersion
        VCIDEInstallDir
        VCINSTALLDIR
        VCToolsInstallDir
        VCToolsRedistDir
        VCToolsVersion
        VisualStudioVersion
        VS160COMNTOOLS
        VSCMD_ARG_app_plat
        VSCMD_ARG_HOST_ARCH
        VSCMD_ARG_TGT_ARCH
        VSCMD_VER
        vsconsoleoutput
        VSINSTALLDIR
        WindowsLibPath
        WindowsSdkBinPath
        WindowsSdkDir
        WindowsSDKLibVersion
        WindowsSdkVerBinPath
        WindowsSDKVersion
        WindowsSDK_ExecutablePath_x64
        WindowsSDK_ExecutablePath_x86
    )

    set(VSVARS_ENV "")
    file(STRINGS ${DETECT_VS_VARS_RESULT_FILE} ConfigContents)
    foreach(NameAndValue ${ConfigContents})
        # Strip spaces
        string(REGEX REPLACE "^[ ]+" "" NameAndValue "${NameAndValue}")
        # Find variable name
        string(REGEX MATCH "^[^=]+" Name ${NameAndValue})
        # Find value
        string(REPLACE "${Name}=" "" Value "${NameAndValue}")

        if ("${Name}" IN_LIST VSVARS_TO_DETECT)
            # message(STATUS "${Name} = ${Value}")
            SET(ENV{${Name}} "${Value}")
        endif()
    endforeach()
endfunction()

create_vs_env()

project(cmake_iwyu)

add_executable(hello main.cpp)

find_program(include-what-you-use NAMES include-what-you-use PATHS "c:/src/misc/include-what-you-use/_build/bin/Release")
if(NOT include-what-you-use)
  message(FATAL_ERROR "Could not find the program include-what-you-use")
endif()

set_property(TARGET hello PROPERTY CXX_INCLUDE_WHAT_YOU_USE "${include-what-you-use};--driver-mode=cl;-Xiwyu;any;-Xiwyu;iwyu;-Xiwyu;--verbose=3;-Xiwyu;args")
