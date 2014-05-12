<select ng-model="target">
    <option ng-repeat="l in locations" value="{{ l.uuid }}"> {{ l.display }} </option>
</select>