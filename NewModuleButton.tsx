import React from 'react';
import {NativeModules, Button} from 'react-native';

const {RNCalendarModule} = NativeModules;

console.log('NativeModuleCalendarModule');
console.log(NativeModules);

const NewModuleButton = () => {
  const onPress = () => {
    console.log(NativeModules);
    console.log('We will invoke the native module here!');
    //RNCalendarModule.createCalendarEvent('testName', 'testLocation');
    NativeModules.HelloWorld.ShowMessage('Awesome!its working!', 2.5);
    console.log('It worked');
  };

  return (
    <Button
      title="Click to invoke your native module!"
      color="#841584"
      onPress={onPress}
    />
  );
};

export default NewModuleButton;
