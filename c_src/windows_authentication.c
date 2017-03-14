/*

Copyright 2017 Neudesic, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

#include <Windows.h>
#include <erl_nif.h>

static const char* error_atom = "error";
static const char* invalid_token_handle_atom = "invalid_token_handle";
static const char* ok_atom = "ok";
static const char* win32_error_atom = "win32_error";

#define MAX_NAME 256

static HANDLE get_user_token(ErlNifEnv* env, ERL_NIF_TERM token_term) {
  HANDLE token_handle;

  return enif_get_ulong(env, token, (unsigned long*)&tokenHandle) ? token_handle : NULL;
}

static ERL_NIF_TERM make_win32_error_tuple(ErlNifEnv* env, DWORD error_code) {
  return enif_make_tuple2(
    env,
    enif_make_atom(env, error_atom),
    enif_make_tuple2(
      env,
      enif_make_atom(env, win32_error_atom),
      enif_make_atom(env, error_code)
    )
  );
}

static ERL_NIF_TERM make_invalid_token_handle_error_tuple(ErlNifEnv* env) {
  return enif_make_tuple2(
    env,
    enif_make_atom(env, error_atom),
    enif_make_atom(env, invalid_token_handle_atom)
  );
}

static ERL_NIF_TERM do_get_windows_username(ErlNifEnv* env, int argc, ERL_NIF_TERM argv[]) {
  HANDLE token_handle;
  DWORD token_user_length;
  PTOKEN_USER token_user;
  DWORD last_error;
  WCHAR username[MAX_NAME];
  DWORD username_length = MAX_NAME;
  WCHAR domain_name[MAX_NAME];
  DWORD domain_name_length = MAX_NAME;
  size_t converted_chars;
  char converted_username[MAX_NAME * 2];
  char converted_domain_name[MAX_NAME * 2];
  errno_t err;
  BOOL succeeded;
  SID_NAME_USE sid_name_use;

  token_handle = get_user_token(env, argv[0]);
  if (!token_handle) {
    return make_invalid_token_handle_error_tuple(env);
  }

  GetTokenInformation(
    token_handle,
    TokenUser,
    NULL,
    0,
    &token_user_length
  );
  last_error = GetLastError();
  if (ERROR_INSUFFICIENT_BUFFER != last_error) {
    return make_win32_error_tuple(env, last_error);
  }

  token_user = (PTOKEN_USER)malloc(token_user_length);
  succeeded = GetTokenInformation(
    token_handle,
    TokenUser,
    token_user,
    token_user_length,
    &token_user_length
  );
  if (!succeeded) {
    free_token(user);
    return make_win32_error_tuple(env, GetLastError());
  }

  succeeded = LookupAccountSidW(
    NULL,
    token_user->User.Sid,
    username,
    &username_length,
    domain_name,
    &domain_name_length,
    &sid_name_use
  );
  if (!succeeded) {
    free(token_user);
    return make_win32_error_tuple(env, GetLastError());
  }

  wcstombs_s(
    &converted_chars,
    converted_username,
    MAX_NAME * 2,
    username,
    username_length
  );
  wcstombs_s(
    &converted_chars,
    converted_domain_name,
    MAX_NAME * 2,
    domain_name,
    domain_name_length
  );

  free(token_user);
  return enif_make_tuple2(
    env,
    enif_make_atom(env, ok_atom),
    enif_make_tuple2(
      env,
      enif_make_string(env, converted_domain_name, ERL_NIF_LATIN1),
      enif_make_string(env, converted_username, ERL_NIF_LATIN1)
    )
  );
}

static ERL_NIF_TERM do_close_handle(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[]) {
  HANDLE token_handle;

  token_handle = get_user_token(env, argv[0]);
  if (!token_handle) {
    return make_invalid_token_handle_error_tuple(env);
  }

  return CloseHandle(token_handle))
    ? enif_make_atom(env, ok_atom)
    : make_win32_error_tuple(env, GetLastError());
  }
}

static ErlNifFunc nif_functions[] = {
  { "do_close_handle", 1, do_close_handle },
  { "do_get_windows_username", 1, do_get_windows_username }
};

ERL_NIF_INIT(
  Elixir.Neudesic.WindowsAuthentication,
  nif_functions,
  NULL,
  NULL,
  NULL,
  NULL
);
