export default async function readfiles(input) {
  let files = [];

  for (let infile of input.files) {
    var reader = new FileReader();
    reader.readAsDataURL(infile, "UTF-8");

    reader.onerror = function (evt) {
      alert("Failed to load file");
    }

    await new Promise((res, rej) => {
      reader.onload = async evt => {
        let file = {
          name: infile.name,
          type: infile.type,
          data: evt.target.result
        };
        await populateImage(file);
        files.push(file);
        res();
      };
    });
  }

  return files;
}
export async function populateImage(file) {
  if (file.type.startsWith('image/')) {
    file.image = new window.Image();
    let pr = new Promise((res, rej) => {
      file.image.onload = res
      file.image.onerror = () => rej(new Error('Failed to load image'));
    });
    file.image.src = file.data;
    await pr;
  }
  return file;
}
