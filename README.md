# Instructions for Chan Lab members

Welcome to the Chan Lab pupillometry repository! This repository allows the
user to analyze a face video of a mouse to determine the pupil size of the
mouse over the course of the video.

Here's a quick introduction to how to use the code.

## Run the example

1. Open the `example/s191113_example.m` script.
2. Change the string literal in line 2 to be the path to this repository.
3. Run the `example/s191113_example.m` script! Follow the instructions to
   produce the pupillometry data.

Note that a description of each argument can be found in the comments of
the `matlab/pupilMeasurement.m` script.

## Create your own

Like the example script, you can create your own script that calls the
pupillometry function on your own face video. Follow the steps below to do
so.

1. Create your own directory called `example_custom/` in this repository.
2. Copy the `example/s191113_example.m` script to `example_custom/`.
3. Rename the `example_custom/s191113_example.m` to
   `example_custom/scustom.m`
4. Copy the video you want to analyze to the `example_custom/` directory.
5. In line 10 of `example_custom/scustom.m`, change the string literal from
   `'example/sample_video.mp4'` to `'example_custom/<video-name>'` where
   <video-name> is the name of the video (including the extension) copied
   in step 4.
6. In line 11 of `example_custom/scustom.m`, change the string literal from
   `'example'` to `'example_custom'`. This ensures that the results will be
   saved to the `example_custom/` directory.
7. Run the `example_custom/scustom.m` script! Follow the promptings to
   produce the pupillometry data. **Important note**: Sometimes, the
   quality of the pupillometry data depends on the diamater line that is
   drawn across the pupil. From experience, there have been times where the
   same video produces drastically different results depending on the
   drawn diameter. If the pupillometry data is not good quality (i.e. there
   are many spikes in the data where the algorithm completely overestimates
   the pupil size), then try running the script again with a different
   start and end point when drawing the pupil diameter.

## The outputs

When a script is run, it produces two files: a CSV file and a .mat file.
Each contain the same data, but in different formats. The CSV file is a
two-column CSV with the frame number down the first column and the pupil
size down the second column. The .mat file is a MATLAB matrix file. It can
be loaded in MATLAB using the `load` function and specifying the path to
the .mat file as the singular argument to this function. The pupillometry
data is contained in a field titled, `R`, of the loaded structure. `R` is
a matrix with two columns, specifying the data in the same order as the CSV
file.

## Clean the data

Once the video has been analyzed and the output files are produced. The
data can be cleaned to:

1. Remove spikes in the data.
2. Linearly interpolate across the removed points.
3. Smooth the data.
4. Obtain areas of interest (peaks and troughs) in the graph.

This can be done by running the `matlab/cleanData.m` script. A description
of the inputs can be found in the script.

## More information

For more information about this repository, please visit
https://ein-lab.github.io/pupillometry-raspi/

pupillometry-matlab
=====

This is an open-source MATLAB-based code bundle to measure and analyze pupil diameter changes. This code is part of a larger toolbox. Please see the [accompanying publication](https://www.nature.com/articles/s41596-020-0324-6), the [user guide](https://ein-lab.github.io/pupillometry-raspi) and the [s191113_example.m](https://github.com/EIN-lab/pupillometry-matlab/blob/master/s191113_example.m) script for more detailed instructions on how to load and analyze data.

Getting Help
------------

### Bug Reports and Further Assistance

Although we are unable to guarantee a response to all requests for assistance, please submit questions or bug reports via the GitHub repository [issues page](https://github.com/EIN-lab/pupillometry-matlab/issues).

Contributing
------------

Please see the [CONTRIBUTING.md](https://github.com/EIN-lab/pupillometry-matlab/tree/master/CONTRIBUTING.md) file for details.

License
-------

This project is licensed under the GNU General Public License. Please see the [LICENSE.txt](https://github.com/EIN-lab/pupillometry-matlab/tree/master/LICENSE.txt) file for details.

Although the GNU General Public License does not permit terms requiring users to cite the research paper where this software was originally published (see [here](https://www.gnu.org/licenses/gpl-faq.en.html#RequireCitation)), we request that any research making use of this software does cite the paper, as well as papers describing any algorithms used, in keeping with normal academic practice.

Authors
-------

Please refer to the [accompanying publication](https://www.nature.com/articles/s41596-020-0324-6) or use the matlab function utils.citation().

Code of Conduct
-------

Please see the [CODE_OF_CONDUCT.md](https://github.com/EIN-lab/pupillometry-matlab/tree/master/CODE_OF_CONDUCT.md) file for details.
