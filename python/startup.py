import itertools
import sys

from pathlib import Path
from textwrap import dedent
from typing import *

T = TypeVar('T')

def sorting_tee(pred: Callable[[T], bool], ibl: Iterable[T]) -> Tuple[Iterator[T], Iterator[T]]:
    """ Return two iterables, the first where `pred` always returns true, the
        other always false for values in the input iterable.

    >>> is_odd = lambda i: i % 2 != 0
    >>> odds, evens = sorting_tee(is_odd, range(5))
    >>> list(odds) == [1, 3]
    True
    >>> list(evens) == [0, 2, 4]
    True

    """
    yes, no = itertools.tee(ibl)
    yes = (item for item in yes if pred(item))
    no = (item for item in no if not(pred(item)))
    return yes, no

def startup_files(templates: Iterable[str]):
    """ Generate all startup files that match `templates` in this or any 
        parent directory (up to the root).

        If a template is absolute, it is checked once. Otherwise, templates
        are checked for each parent directory, in reverse. That is, if the
        CWD is "/usr/local/src", and the template is "startup.py", then
        the paths checked are "/startup.py", "/usr/startup.py", 
        "/usr/local/startup.py", "/usr/local/src/startup.py". This ordering 
        enables deeper files to overrule shallower files.

    """
    absolute, relative = sorting_tee(lambda p: p.is_absolute(), 
                                     (Path(s) for s in templates))

    # Capture cwd before any yields, in case the directory is changed.
    cwd = Path.cwd()
    root_to_cwd = list(reversed(cwd.parents))
    root_to_cwd.append(cwd)

    # Process absolute files first - they're likely per-user files that might
    # be overridden by the local project files.

    visited = set()

    for p in absolute:
        if p not in visited and p.exists() and p.is_file():
            visited.add(p)
            yield p

    for rel in relative:
        for base in root_to_cwd:
            p = base / rel
            if p not in visited and p.exists() and p.is_file:
                visited.add(p)
                yield p

STARTUP_FILES = dedent("""
    startup.py
    .startup.py
    _startup.py
    etc/startup.py
""").strip().split('\n')
    
if __name__ == '__main__':
    mod = sys.modules[__name__]

    if not hasattr(mod, 'AGHAST_STARTUP_DONE'):
        # Recursion guard. Do not remove this variable or the test above.
        AGHAST_STARTUP_DONE = True

        for f in startup_files(STARTUP_FILES):
            print("processing {}".format(f))
            exec(compile(open(str(f)).read(), str(f), 'exec'))

