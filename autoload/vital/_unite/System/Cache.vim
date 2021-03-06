" Utilities for output cache.

let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:V = a:V
  let s:S = s:V.import('Data.String')
endfunction

function! s:_vital_depends() abort
  return ['Data.String']
endfunction

function! s:getfilename(cache_dir, filename) abort
  return s:_encode_name(a:cache_dir, a:filename)
endfunction

function! s:filereadable(cache_dir, filename) abort
  let cache_name = s:_encode_name(a:cache_dir, a:filename)
  return filereadable(cache_name)
endfunction

function! s:readfile(cache_dir, filename) abort
  let cache_name = s:_encode_name(a:cache_dir, a:filename)
  return filereadable(cache_name) ? readfile(cache_name) : []
endfunction

function! s:writefile(cache_dir, filename, list) abort
  let cache_name = s:_encode_name(a:cache_dir, a:filename)

  call writefile(a:list, cache_name)
endfunction

function! s:delete(cache_dir, filename) abort
  echoerr 'System.Cache.delete() is obsolete. Use its deletefile() instead.'
  return call('s:deletefile', a:cache_dir, a:filename)
endfunction

function! s:deletefile(cache_dir, filename) abort
  let cache_name = s:_encode_name(a:cache_dir, a:filename)
  return delete(cache_name)
endfunction

function! s:_encode_name(cache_dir, filename) abort
  " Check cache directory.
  if !isdirectory(a:cache_dir)
    call mkdir(a:cache_dir, 'p')
  endif
  let cache_dir = a:cache_dir
  if cache_dir !~ '/$'
    let cache_dir .= '/'
  endif

  return cache_dir . s:_create_hash(cache_dir, a:filename)
endfunction

function! s:check_old_cache(cache_dir, filename) abort
  " Check old cache file.
  let cache_name = s:_encode_name(a:cache_dir, a:filename)
  let ret = getftime(cache_name) == -1
        \ || getftime(cache_name) <= getftime(a:filename)
  if ret && filereadable(cache_name)
    " Delete old cache.
    call delete(cache_name)
  endif

  return ret
endfunction

function! s:_create_hash(dir, str) abort
  if len(a:dir) + len(a:str) < 150
    let hash = substitute(substitute(
          \ a:str, ':', '=-', 'g'), '[/\\]', '=+', 'g')
  else
    let hash = s:S.hash(a:str)
  endif

  return hash
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
