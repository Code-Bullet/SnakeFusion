
class Matrix {
  
  //local variables
  int rows;
  int cols;
  float[][] matrix;
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //constructor
  Matrix(int r, int c) {
    rows = r;
    cols = c;
    matrix = new float[rows][cols];
  }
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //constructor from 2D array
  Matrix(float[][] m) {
    matrix = m;
    cols = m.length;
    rows = m[0].length;
  }
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //print matrix
  void output() {
    for (int i =0; i<rows; i++) {
      for (int j = 0; j<cols; j++) {
        print(matrix[i][j] + "  ");
      }
      println(" ");
    }
    println();
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  
  //multiply by scalar
  void multiply(float n ) {

    for (int i =0; i<rows; i++) {
      for (int j = 0; j<cols; j++) {
        matrix[i][j] *= n;
      }
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //return a matrix which is this matrix dot product parameter matrix 
  Matrix dot(Matrix n) {
    Matrix result = new Matrix(rows, n.cols);
   
    if (cols == n.rows) {
      //for each spot in the new matrix
      for (int i =0; i<rows; i++) {
        for (int j = 0; j<n.cols; j++) {
          float sum = 0;
          for (int k = 0; k<cols; k++) {
            sum+= matrix[i][k]*n.matrix[k][j];
          }
          result.matrix[i][j] = sum;
        }
      }
    }

    return result;
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //set the matrix to random ints between -1 and 1
  void randomize() {
    for (int i =0; i<rows; i++) {
      for (int j = 0; j<cols; j++) {
        matrix[i][j] = random(-1, 1);
      }
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //add a scalar to the matrix
  void Add(float n ) {
    for (int i =0; i<rows; i++) {
      for (int j = 0; j<cols; j++) {
        matrix[i][j] += n;
      }
    }
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  ///return a matrix which is this matrix + parameter matrix
  Matrix add(Matrix n ) {
    Matrix newMatrix = new Matrix(rows, cols);
    if (cols == n.cols && rows == n.rows) {
      for (int i =0; i<rows; i++) {
        for (int j = 0; j<cols; j++) {
          newMatrix.matrix[i][j] = matrix[i][j] + n.matrix[i][j];
        }
      }
    }
    return newMatrix;
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //return a matrix which is this matrix - parameter matrix
  Matrix subtract(Matrix n ) {
    Matrix newMatrix = new Matrix(cols, rows);
    if (cols == n.cols && rows == n.rows) {
      for (int i =0; i<rows; i++) {
        for (int j = 0; j<cols; j++) {
          newMatrix.matrix[i][j] = matrix[i][j] - n.matrix[i][j];
        }
      }
    }
    return newMatrix;
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //return a matrix which is this matrix * parameter matrix (element wise multiplication)
  Matrix multiply(Matrix n ) {
    Matrix newMatrix = new Matrix(rows, cols);
    if (cols == n.cols && rows == n.rows) {
      for (int i =0; i<rows; i++) {
        for (int j = 0; j<cols; j++) {
          newMatrix.matrix[i][j] = matrix[i][j] * n.matrix[i][j];
        }
      }
    }
    return newMatrix;
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //return a matrix which is the transpose of this matrix
  Matrix transpose() {
    Matrix n = new Matrix(cols, rows);
    for (int i =0; i<rows; i++) {
      for (int j = 0; j<cols; j++) {
        n.matrix[j][i] = matrix[i][j];
      }
    }
    return n;
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //Creates a single column array from the parameter array
  Matrix singleColumnMatrixFromArray(float[] arr) {
    Matrix n = new Matrix(arr.length, 1);
    for (int i = 0; i< arr.length; i++) {
      n.matrix[i][0] = arr[i];
    }
    return n;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //sets this matrix from an array
  void fromArray(float[] arr) {
    for (int i = 0; i< rows; i++) {
      for (int j = 0; j< cols; j++) {
        matrix[i][j] =  arr[j+i*cols];
      }
    }
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------    
  //returns an array which represents this matrix
  float[] toArray() {
    float[] arr = new float[rows*cols];
    for (int i = 0; i< rows; i++) {
      for (int j = 0; j< cols; j++) {
        arr[j+i*cols] = matrix[i][j];
      }
    }
    return arr;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //for ix1 matrixes adds one to the bottom
  Matrix addBias() {
    Matrix n = new Matrix(rows+1, 1);
    for (int i =0; i<rows; i++) {
      n.matrix[i][0] = matrix[i][0];
    }
    n.matrix[rows][0] = 1;
    return n;
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //applies the activation function(sigmoid) to each element of the matrix
  Matrix activate() {
    Matrix n = new Matrix(rows, cols);
    for (int i =0; i<rows; i++) {
      for (int j = 0; j<cols; j++) {
        n.matrix[i][j] = sigmoid(matrix[i][j]);
      }
    }
    return n;
  }
  
//---------------------------------------------------------------------------------------------------------------------------------------------------------    
  //sigmoid activation function
  float sigmoid(float x) {
    float y = 1 / (1 + pow((float)Math.E, -x));
    return y;
  }
  //returns the matrix that is the derived sigmoid function of the current matrix
  Matrix sigmoidDerived() {
    Matrix n = new Matrix(rows, cols);
    for (int i =0; i<rows; i++) {
      for (int j = 0; j<cols; j++) {
        n.matrix[i][j] = (matrix[i][j] * (1- matrix[i][j]));
      }
    }
    return n;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //returns the matrix which is this matrix with the bottom layer removed
  Matrix removeBottomLayer() {
    Matrix n = new Matrix(rows-1, cols);      
    for (int i =0; i<n.rows; i++) {
      for (int j = 0; j<cols; j++) {
        n.matrix[i][j] = matrix[i][j];
      }
    }
    return n;
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //Mutation function for genetic algorithm 
  
  void mutate(float mutationRate) {
    
    //for each element in the matrix
    for (int i =0; i<rows; i++) {
      for (int j = 0; j<cols; j++) {
        float rand = random(1);
        if (rand<mutationRate) {//if chosen to be mutated
          matrix[i][j] += randomGaussian()/5;//add a random value to it(can be negative)
          
          //set the boundaries to 1 and -1
          if (matrix[i][j]>1) {
            matrix[i][j] = 1;
          }
          if (matrix[i][j] <-1) {
            matrix[i][j] = -1;
          }
        }
      }
    }
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //returns a matrix which has a random number of values from this matrix and the rest from the parameter matrix
  Matrix crossover(Matrix partner) {
    Matrix child = new Matrix(rows, cols);
    
    //pick a random point in the matrix
    int randC = floor(random(cols));
    int randR = floor(random(rows));
    for (int i =0; i<rows; i++) {
      for (int j = 0; j<cols; j++) {

        if ((i< randR)|| (i==randR && j<=randC)) { //if before the random point then copy from this matric
          child.matrix[i][j] = matrix[i][j];
        } else { //if after the random point then copy from the parameter array
          child.matrix[i][j] = partner.matrix[i][j];
        }
      }
    }
    return child;
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //return a copy of this matrix
  Matrix clone() {
    Matrix clone = new  Matrix(rows, cols);
    for (int i =0; i<rows; i++) {
      for (int j = 0; j<cols; j++) {
        clone.matrix[i][j] = matrix[i][j];
      }
    }
    return clone;
  }
}