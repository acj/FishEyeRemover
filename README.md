# FishEyeRemover

A simple algorithm (and sample iOS project) for removing the fisheye effect from photos. 

## Demo

Build and run the project to see the algorithm in action.

Sample output:

!["Sample output"](http://content.screencast.com/users/a.jensen/folders/Snagit/media/b0c595f7-1f2d-4823-be67-b12d26c35773/2015-05-09_12-32-38.png)

## Photo Compatibility

I tested this on photos from a GoPro Hero 3. It should work with any photo at any resolution, but the results will vary depending on the severity of the fisheye distortion and the parameters that you choose.

Refer to the source code (specifically `ViewController.m`) for tuning instructions.

## Credits

Based on an [algorithm](http://www.tannerhelland.com/4743/simple-algorithm-correcting-lens-distortion/) for correcting lens distortion by [Tanner Helland](http://www.tannerhelland.com).

## License

Apache 2. See `LICENSE` for details.
