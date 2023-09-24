#ifndef MINICMAKEDEMOLIB_COREEXPORT_H
#define MINICMAKEDEMOLIB_COREEXPORT_H


#if defined(MiniCmakeDemoLib_API_EXPORTS)
#ifdef _WIN32
#define MINICMAKEDEMOLIB_API_EXPORT __declspec(dllexport)
#else
#define MINICMAKEDEMOLIB_API_EXPORT __attribute__ ((visibility ("default")))
#endif
#else
#ifdef _WIN32
#define MINICMAKEDEMOLIB_API_EXPORT __declspec(dllimport)
#else
#define MINICMAKEDEMOLIB_API_EXPORT
#endif
#endif

#ifndef _WIN32
#define MINICMAKEDEMOLIB_API_EXPORT_NON_WIN32 MINICMAKEDEMOLIB_API_EXPORT
#else
#define MINICMAKEDEMOLIB_API_EXPORT_NON_WIN32
#endif




#endif //MINICMAKEDEMOLIB_COREEXPORT_H
