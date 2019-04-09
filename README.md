# Casting Orientation Optimization

Graphical tool and high-performance computing scripts for orientation optimization of castings based on [Casting Geometric Toolsuite](https://github.com/wwarriner/casting_geometric_toolsuite).

This repository is under heavy construction. Please excuse the lack of documentation, outdated documentation, and general clutter.

### Usage

Run `extend_search_path.m` to add the folder and subfolders to the MATLAB `path`. Navigate to the `sample` subfolder, and run `plot_sample_data.m` to test the tool. You should see a graphical user interface similar to the one shown below.

![User interface example.](https://github.com/wwarriner/casting_orientation_optimization/blob/master/doc/img/tool_demo.png)

The upper-right contains a map of orientations. The horizontal axis of the map represents rotations about the original X-axis of the input model, while the vertical axis corresponds to rotations about the original Y-axis. Points on the map represent values corresponding to data filtered by selections on widgets in the panels at left. The bottom-right contains a parallel coordinates plot of the objective values plotted on the map. The gray lines represent pareto front points excluded by the current threshold selections, while orange lines are those that meet the threshold criteria.

#### Selecting a point.

Clicking on the map selects a point. The text widget at the top shows the rotation about X and Y---and the value of---the selected point. The selected point is denoted by a sky blue diamond symbol. The listbox widget below the text widget allows selection of one of the objectives to display in the map. The value in the text widget is based on the listbox selection, and either reflects the raw values or the quantiles, depending on the Data Mode.

#### What does the `Visualize Selected Point...` button do?

Once a value is selected on the map, users may click the `Visualize Selected Point...` button to see a visualization of the reoriented geometry, complete with cope, drag, feeders, and reference axes for the original input orientation.

#### What are the green and orange points?

The green points are those members of the pareto front which do not meet the current threshold selection when the `Go/No-Go` `Threshold Type` is selected. Orange points are those members which do meet the thresholds. Note that the `Show Pareto Front` checkbox must be ticked for these points to show.

#### What are the light and dark regions of the map?

When using `Go/No-Go` and `Threshold On` `Threshold Types`, the map is binarized. The darker color represents those points that are above the relevant threshold or thresholds. The lighter color represents those that are below the threshold or thresholds.

#### What does Go/No-Go mean?

The `Go/No-Go` `Threshold Type` means that all of the checked thresholds are accounted for when binarizing the image. The raw data is thresholded by the selected thresholds individually, and the results of each thresholding is logically `and`ed together, resulting in greater restriction than any one threshold alone. The purpose of this is to help users manage tradeoffs to determine an ideal orientation for their particular needs.

#### Why do I have to do all this work?

While it would be nice to provide users with an unambiguous method for determining a single, optimal orientation, there does not exist any means to do so. Non-trivial multi-objective optimization problems always involve trade-offs, and the needs of our users are not uniform. It wouldn't make sense for us to impose a single metric on all our users. If you are interested in researching a single-objective optimization metric, please contact us.

#### How can I change the thresholds?

Thresholds may be turned on or off by clicking the checkboxes next to the name in the `Thresholds` panel. The values may be changed by directly entering a value in the edit text boxes, or by using the provided sliders. The user may also click on in the space above one of the objective variables on the parallel coordinate plot to select a threshold in relation to its value scaled to those values of the pareto front. The selection is reflected visually on the parallel coordinates plot by a black plus sign. If there is no black plus sign, then the threshold is not being used to limit the pareto front.

### Included Samples

![Base Plate sample geometry.](https://github.com/wwarriner/casting_orientation_optimization/blob/master/doc/img/base_plate.png)

![Bearing Block sample geometry.](https://github.com/wwarriner/casting_orientation_optimization/blob/master/doc/img/bearing_block.png)

![Steering Column Mount sample gometry.](https://github.com/wwarriner/casting_orientation_optimization/blob/master/doc/img/steering_column_mount.png)

#### Geometry Sources

- `base_plate.stl` is [casting by catia](https://grabcad.com/library/casting-by-catia-1) from [GrabCad](www.grabcad.com) by user [RiBKa aTIKA](https://grabcad.com/ribka.atika-1)
- `steering_column_mount.stl` is [Steering Column Mount](https://grabcad.com/library/steering-column-mount-1) from [GrabCad](www.grabcad.com) by user [Christian Mele](https://grabcad.com/christian.mele-1)
- `bearing_block.stl` is a 3D implementation of a 2D drawing from _Directional Solidification of Steel Castings_, R Wlodawer, Pergamon Press, Oxford, UK, 1966. ISBN: 9781483149110. Available from [Amazon](http://a.co/d/3Lwgh1f)
