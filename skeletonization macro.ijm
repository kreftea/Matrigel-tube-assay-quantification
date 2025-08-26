// === Define input and output ===
mainDir = getDirectory("Choose the main folder with images");
outputDir = getDirectory("Choose the output folder");
File.makeDirectory(outputDir);
entries = getFileList(mainDir);
subDirs = newArray();  
imageFiles = newArray();  

for (i = 0; i < entries.length; i++) {
    entryPath = mainDir + entries[i];
    if (File.isDirectory(entryPath)) {
        subDirs = Array.concat(subDirs, entries[i]);  
    } else if (endsWith(entries[i], ".tif")) {
        imageFiles = Array.concat(imageFiles, entries[i]);  
    }
}

print("Main Directory: " + mainDir);
print("Subdirectories found: " + subDirs.length);
print("Images found in main directory: " + imageFiles.length);

// === Process images in the main directory ===
for (i = 0; i < imageFiles.length; i++) {
    imagePath = mainDir + imageFiles[i];
    print("Processing image in main directory: " + imagePath);
    
    open(imagePath);
    run("8-bit");
    run("Subtract Background...", "rolling=50 light");
    run("Bandpass Filter...", "filter_large=40 filter_small=10 suppress=None tolerance=5");
    
    setAutoThreshold("Otsu");
    getThreshold(lower, upper);
    lower = upper * 0.85;
    setThreshold(lower, upper);
    run("Convert to Mask");
    
    run("Make Binary");
    run("Open");
    run("Close-");
    run("Skeletonize");

    savePath = outputDir + imageFiles[i];
    print("Saving image to: " + savePath);
    saveAs("Tiff", savePath);
    close();
}

// === Process images in each subdirectory ===
for (j = 0; j < subDirs.length; j++) {
    subfolderPath = mainDir + subDirs[j] + "/";
    print("Processing folder: " + subfolderPath);
    
    subImages = getFileList(subfolderPath);
    
    print("Images found in " + subfolderPath + ": " + subImages.length);
    
    for (i = 0; i < subImages.length; i++) {
        if (endsWith(subImages[i], ".tif")) {
            imagePath = subfolderPath + subImages[i];
            print("Opening image: " + imagePath);
            open(imagePath);

            run("8-bit");
            run("Subtract Background...", "rolling=50 light");
            run("Bandpass Filter...", "filter_large=40 filter_small=10 suppress=None tolerance=5");
            
            setAutoThreshold("Otsu");
            getThreshold(lower, upper);
            lower = upper * 0.85;
            setThreshold(lower, upper);
            run("Convert to Mask");
            
            run("Make Binary");
            run("Open");
            run("Close-");
            run("Skeletonize");

            savePath = outputDir + subDirs[j] + "_" + subImages[i];
            print("Saving image to: " + savePath);
            saveAs("Tiff", savePath);
            close();
        }
    }
}

