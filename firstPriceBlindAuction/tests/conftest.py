import pathlib
import logging

import tonos_ts4.ts4 as ts4

from pytest import fixture


LOGGER = logging.getLogger(__name__)


@fixture(scope='function')
def fix_path(pytestconfig):
    # ts4.reset_all()
    rootpath: pathlib.Path = pytestconfig.rootpath
    ts4.init(rootpath.joinpath('contracts/'), verbose=False)
