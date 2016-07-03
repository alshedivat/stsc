Supervised Transfer Sparse Coding
=================================

A MATLAB implementation of the STSC algorithm that makes use of LIBSVM and LIBLINEAR for prediction.
Additionally, we provide handwritten digits data used in the experiments of the original paper, a few example scripts for running experiments and cross-validating in parallel on a multi-core machine, and utility functions for visualization.

### Download

The code and data can be donwloaded directly as a [zip-file](https://github.com/alshedivat/stsc/releases/download/v1.0/latest.zip) (200MB).
Alternatively, you may clone the repository:

```bash
$ git clone --recursive git@github.com:alshedivat/stsc.git
```

**Note:** You need to clone *recursively* as STSC depends on LIBSVM and LIBLINEAR submodules.

### Installation

After downloading/cloning the code, you just need to mex-compile LIBSVM and LIBLINEAR libraries.
This is done from MATLAB by executing `make` script in `code/libsvm` and `code/liblinear` subfolders:
```bash
$ matlab -nodisplay -nosplash
[...]
>> cd code/liblinear/matlab
>> make
>> cd ../libsvm/matlab
>> make
```

### Usage

The code is executed by simply running scripts given in the `code` subfolder.
First, generate a config using `GetConfiguration` function.
Next, run one of the scripts, e.g., `SingleRun` or `CrossValidation`.
For more details, please refer to the code; it's written in a clean and neat way.

### Citation
If you use this code (in full or in part) for academic purposes, please consider citing our paper:

```bibtex
@inproceedings{alshedivat2014stsc,
  title={Supervised Transfer Sparse Coding},
  author={Al-Shedivat, Maruan and Wang, Jim Jing-Yan and Alzahrani, Majed and Huang, Jianhua Z and Gao, Xin},
  booktitle={Proceedings of the Twenty-Eighth AAAI Conference on Artificial Intelligence},
  year={2014},
  organization={The AAAI Press}
}
```

### License

MIT (for details, please refer to [LICENSE](https://github.com/alshedivat/stsc/blob/master/LICENSE))

Copyright (c) 2014 Maruan Al-Shedivat
