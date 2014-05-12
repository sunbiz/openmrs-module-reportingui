<select ng-model="target">
    <option ng-repeat="et in encounterTypes" value="{{ et.uuid }}"> {{ et.display }} </option>
</select>