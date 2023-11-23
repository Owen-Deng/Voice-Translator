import numpy as np
import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from pymongo import MongoClient
import turicreate as tc
from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import train_test_split
from joblib import dump, load
import os

app = FastAPI()

@app.post("/AddDataPoint")
async def AddDataPoint(request: Request):
    '''Save data point and class label to database
    '''
    print(request.client.host)
    data = await request.json()

    vals = data['feature']
    fvals = [float(val) for val in vals]
    label = data['label']
    sess  = data['dsid']

    dbid = db.labeledinstances.insert_one(
        {"feature":fvals,"label":label,"dsid":sess}
        )
    return JSONResponse({"id":str(dbid),
        "feature":[str(len(fvals))+" Points Received",
                "min of: " +str(min(fvals)),
                "max of: " +str(max(fvals))],
        "label":label})


@app.get("/UpdateModel")
async def UpdateModel(dsid: int = 0):
    '''Train two new models (or update) for given dataset ID
    '''
    # create feature vectors and labels from database
    features = []
    labels   = []
    for a in db.labeledinstances.find({"dsid":dsid}): 
        features.append([float(val) for val in a['feature']])
        labels.append(a['label'])
    
    if not labels:
        return JSONResponse({"KNNAccuracy": -1, "BTAccuracy": -1, "msg": f"no data when dsid={dsid}"})
    
    if len(np.unique(labels)) < 2:
        return JSONResponse({"KNNAccuracy": -1, "BTAccuracy": -1, "msg": "at least two classes"})
    
    # split training and testing sets
    X_train, X_test, y_train, y_test = train_test_split(features, labels, train_size = 0.7)
    if not y_test:
        # not enough data
        return JSONResponse({"KNNAccuracy": -1, "BTAccuracy": -1, "msg": "data insufficient"})
    
    
    ###### KNN
    global KNNclf
    KNNacc = -1
    model = KNeighborsClassifier(n_neighbors=1)
    # fit the model to the data
    model.fit(X_train,y_train) # training
    lstar = model.predict(X_test)
    KNNclf = model
    KNNacc = sum(lstar==y_test)/float(len(y_test))
    
    # just write this to model files directory
    os.makedirs("models", exist_ok=True)
    dump(model, 'models/knn_model_dsid%d.joblib'%(dsid))
        
    
    ####### BT 
    BTacc = -1
    data = {'target':y_train, 'sequence':np.array(X_train)}
    data = tc.SFrame(data=data)
    global BTclf
    model = tc.classifier.boosted_trees_classifier.create(data, target='target',verbose=0)# training
    yhat = model.predict(tc.SFrame(data={'sequence':np.array(X_test)}))
    BTclf = model
    BTacc = sum(yhat.to_numpy()==y_test)/float(len(y_test))
    
    # save model for use later, if desired
    os.makedirs("models", exist_ok=True)
    model.save('models/turi_model_dsid%d'%(dsid))
            
    # send back the accuracies
    return JSONResponse({"KNNAccuracy": KNNacc, "BTAccuracy": BTacc})
    

@app.post("/PredictOne")
async def PredictOne(request: Request, model_name: str = "KNN"):
    '''Predict the class of a sent feature vector
    '''
    if model_name not in supported_models:
        return "model not supported!"
    
    data = await request.json()   
    
    vals = data['feature']
    fvals = [float(val) for val in vals]
    fvals = np.array(fvals).reshape(1, -1)
    dsid  = data['dsid']

    # load the model (using pickle)
    if model_name == "KNN":
        global KNNclf
        if not KNNclf:
            # load from file if needed
            print('Loading Model From DB')
            tmp = load('models/knn_model_dsid%d.joblib'%(dsid)) 
            KNNclf = tmp
        
        predLabel = KNNclf.predict(fvals)
    else:
        # load the model from the database (using pickle)
        # we are blocking tornado!! no!!
        global BTclf
        if not BTclf:
            print('Loading Model From file')
            BTclf = tc.load_model('models/turi_model_dsid%d'%(dsid))
        predLabel = BTclf.predict(tc.SFrame(data={'sequence':np.array(fvals)}))
  
    
    return JSONResponse({"prediction":str(predLabel[0])})


if __name__ == "__main__":
    supported_models = ["KNN", "BT"]
    client = MongoClient(serverSelectionTimeoutMS=50)
    db = client.turidatabase
    KNNclf, BTclf = None, None
    uvicorn.run(app, host="0.0.0.0", port=8080)