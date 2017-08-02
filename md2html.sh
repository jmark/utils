#!/usr/bin/bash

CSS='body {
    margin-left: 20%;
    margin-right: 20%;
}

li, p {
    text-align: justify;
    font-family: Baskerville, “Baskerville Old Face”, “Hoefler Text”, Garamond, “Times New Roman”, serif;
}

h1,h2,h3 {
    text-align: center;
}

'

HTML=$(markdown "$*")

cat << END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html>
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<style>
${CSS}
</style>
<script type="text/javascript" async
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
</script>
</head>
<body>
${HTML}
</body>
</html>END
