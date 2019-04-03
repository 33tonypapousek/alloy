const getScreenOrientation = window => {
  const { screen } = window;
  const { orientation, width, height } = screen;

  if (orientation == null) {
    return width > height ? "landscape" : "portrait";
  }

  if (orientation.type == null) {
    return null;
  }

  const parts = orientation.type.split("-");

  if (parts.length === 0) {
    return null;
  }

  return parts[0] || null;
};

export default window => {
  return () => {
    const {
      screen: { width, height }
    } = window;
    const orientation = getScreenOrientation(window);

    return {
      device: {
        screenHeight: height,
        screenWidth: width,
        screenOrientation: orientation
      }
    };
  };
};
