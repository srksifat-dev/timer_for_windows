#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  HMONITOR primaryMonitor = ::MonitorFromWindow(nullptr, MONITOR_DEFAULTTOPRIMARY);
  MONITORINFO monitorInfo;
  monitorInfo.cbSize = sizeof(MONITORINFO);
  ::GetMonitorInfo(primaryMonitor, &monitorInfo);
  int screenWidth = monitorInfo.rcMonitor.right - monitorInfo.rcMonitor.left;
  int screenHeight = monitorInfo.rcMonitor.bottom - monitorInfo.rcMonitor.top;

  FlutterWindow window(project);
  Win32Window::Point origin(screenWidth - 280, screenHeight - 150);
  Win32Window::Size size(280, 120);
  if (!window.Create(L"timer", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
