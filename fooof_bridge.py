# fooof_bridge.py
#
# Helper to run FOOOF from MATLAB and return a result object
# with attributes compatible with the original fooof_mat wrapper.

import numpy as np
from fooof import FOOOF
from fooof.sim.gen import gen_aperiodic


class MatlabFOOOFResult:
    """Simple container exposing FOOOF outputs with MATLAB-friendly names."""
    def __init__(self, freqs, fm):
        # Spectral vectors
        self.fooofed_spectrum = fm.fooofed_spectrum_

        # Aperiodic fit: try attribute, otherwise generate from params
        ap_fit = getattr(fm, "_ap_fit", None)
        if ap_fit is None:
            ap_fit = gen_aperiodic(freqs, fm.aperiodic_params_, fm.aperiodic_mode)
        self.ap_fit = ap_fit

        # Parameters and fit metrics
        self.aperiodic_params = fm.aperiodic_params_
        self.peak_params      = fm.peak_params_
        self.gaussian_params  = fm.gaussian_params_
        self.r_squared        = fm.r_squared_
        self.error            = fm.error_


def run_fooof(freqs, powspec, f_range, settings=None, return_model=True):
    """
    Run FOOOF on a single power spectrum and return a MatlabFOOOFResult.

    Parameters
    ----------
    freqs : iterable of float
        Frequency vector (Hz).
    powspec : iterable of float
        Power spectrum values.
    f_range : length-2 iterable of float
        [f_min, f_max] fit range in Hz.
    settings : dict, optional
        Keyword arguments for FOOOF (e.g. peak_width_limits, aperiodic_mode).
    return_model : bool, optional
        Kept only for API symmetry with MATLAB wrapper.

    Returns
    -------
    MatlabFOOOFResult
    """
    freqs = np.asarray(list(freqs), dtype=float)
    powspec = np.asarray(list(powspec), dtype=float)

    if len(f_range) != 2:
        raise ValueError("f_range must be length-2 iterable [f_min, f_max].")
    f_min = float(f_range[0])
    f_max = float(f_range[1])
    fit_range = [f_min, f_max]

    if settings is None:
        settings = {}

    fm = FOOOF(**settings)
    fm.fit(freqs, powspec, fit_range)

    return MatlabFOOOFResult(freqs, fm)
